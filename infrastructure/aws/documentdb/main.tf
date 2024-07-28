terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "5.17.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}

data "aws_vpc" "main" {
  tags = { Name = "${var.project_name}-vpc" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_security_group" "document_db" {
  name = "${var.project_name}-document-db-sg"
}


resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb5.0"
  name        = "main"
  description = "docdb cluster parameter group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${var.project_name}-docdb-cluster"
  engine                          = "docdb"
  master_username                 = var.documentdb_user
  master_password                 = var.documentdb_password
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  vpc_security_group_ids          = [data.aws_security_group.document_db.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project_name}-documentdb"
  }
}

resource "aws_docdb_cluster_instance" "main" {
  count              = 1
  identifier         = "tf-${var.project_name}-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"
}


resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-document-db-subnet-group"
  subnet_ids = data.aws_subnets.private.ids[*]

  tags = {
    Name = "${var.project_name}-subnet-group"
  }
}
