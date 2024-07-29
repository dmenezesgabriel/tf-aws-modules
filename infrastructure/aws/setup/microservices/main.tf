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
  subnet_ids                       = module.vpc.private_subnets_ids[*]
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
  subnet_ids                     = module.vpc.private_subnets_ids[*]
  vpc_security_group_ids         = [aws_security_group.document_db_sg.id]
  save_to_ssm                    = true
}

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

module "bastion" {
  source = "../../modules/bastion"

  name                         = "main"
  aws_profile                  = var.aws_profile
  aws_region_name              = var.aws_region_name
  project_name                 = var.project_name
  ec2_instance_type            = "t2.micro"
  ec2_instance_ami             = data.aws_ssm_parameter.ecs_node_ami.value
  subnet_id                    = module.vpc.public_subnets_ids[0]
  vpc_security_group_ids       = [aws_security_group.bastion_host.id]
  ec2_instance_connection_type = "ssh"
  ec2_instance_connection_user = "ec2-user"
  provisioner_remote_exec = [
    # Add the MongoDB repository
    "echo '[mongodb-org-7.0]' | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo",
    "echo 'name=MongoDB Repository' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
    "echo 'baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/7.0/x86_64/' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
    "echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
    "echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
    "echo 'gpgkey=https://pgp.mongodb.com/server-7.0.asc' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",

    # Install the MongoDB shell package
    "sudo yum install -y mongodb-org",

    # Add the PostgreSQL repository
    "sudo amazon-linux-extras enable postgresql16",

    # Install the PostgreSQL client
    "sudo yum install -y postgresql",

    # Install bind-utils
    "sudo yum install -y bind-utils"
  ]
  save_to_ssm = true
}
