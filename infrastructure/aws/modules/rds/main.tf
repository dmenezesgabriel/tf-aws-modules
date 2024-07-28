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

resource "aws_db_instance" "main" {
  allocated_storage      = var.rds_instance_allocated_storage
  engine                 = var.rds_instance_engine
  engine_version         = var.rds_instance_engine_version
  instance_class         = var.rds_instance_class
  db_name                = var.rds_instance_db_name
  username               = var.rds_instance_user
  password               = var.rds_instance_password
  publicly_accessible    = var.rds_instance_publicly_accessible
  skip_final_snapshot    = var.rds_instance_skip_final_snapshot
  vpc_security_group_ids = var.vpc_security_group_ids

  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project_name}-${var.name}-rds-instance"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.name}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.name}-rds-subnet-group"
  }
}
