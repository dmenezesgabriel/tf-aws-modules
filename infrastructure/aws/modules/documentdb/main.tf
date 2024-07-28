terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}

resource "aws_docdb_cluster_parameter_group" "main" {
  count  = var.documentdb_disable_tls ? 1 : 0
  family = var.documentdb_family

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${var.project_name}-${var.name}-docdb-cluster"
  engine                          = var.documentdb_engine
  master_username                 = var.documentdb_user
  master_password                 = var.documentdb_password
  skip_final_snapshot             = var.documentdb_skip_final_snapshot
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  port                            = var.documentdb_port

  tags = {
    Name = "${var.project_name}-${var.name}-documentdb-cluster"
  }
}

resource "aws_docdb_cluster_instance" "main" {
  count              = var.documentdb_instance_count
  identifier         = "${var.project_name}-${name}-documentdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.documentdb_instance_class

  tags = {
    Name = "${var.project_name}-${var.name}-documentdb-instance-${count.index}"
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-document-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-subnet-group"
  }
}
