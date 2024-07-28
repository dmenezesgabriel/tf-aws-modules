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


module "vpc" {
  source = "../../modules/vpc"

  aws_profile              = var.aws_profile
  aws_region_name          = var.aws_region_name
  project_name             = var.project_name
  availability_zones_count = 2
}

module "rds" {
  source = "../../modules/rds"

  name                             = "main"
  aws_profile                      = var.aws_profile
  aws_region_name                  = var.aws_region_name
  project_name                     = var.project_name
  rds_instance_allocated_storage   = 20
  rds_instance_class               = "db.t3.micro"
  rds_instance_engine              = "postgres"
  rds_instance_engine_version      = "16.3"
  rds_instance_db_name             = "postgres"
  rds_instance_user                = "postgres"
  rds_instance_password            = "postgres"
  rds_instance_port                = "5432"
  rds_instance_publicly_accessible = false
  rds_instance_skip_final_snapshot = true
  vpc_security_group_ids           = [aws_security_group.rds_sg.id]
  subnet_ids                       = module.vpc.private_subnets[*].id
  save_to_ssm                      = true
}

module "documentdb" {
  source = "../../modules/documentdb"

  name                           = "main"
  aws_profile                    = var.aws_profile
  aws_region_name                = var.aws_region_name
  project_name                   = var.project_name
  documentdb_engine              = "docdb"
  documentdb_user                = "documentdb"
  documentdb_password            = "documentdb"
  documentdb_port                = 27017
  documentdb_instance_count      = 1
  documentdb_instance_class      = "db.t3.medium"
  documentdb_skip_final_snapshot = true
  documentdb_disable_tls         = true
  subnet_ids                     = module.vpc.private_subnets[*].id
  vpc_security_group_ids         = [aws_security_group.document_db_sg.id]
  save_to_ssm                    = true
}
