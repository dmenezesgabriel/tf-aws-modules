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

# module "documentdb" {
#   source = "../../modules/documentdb"

#   name                           = "main"
#   aws_profile                    = var.aws_profile
#   aws_region_name                = var.aws_region_name
#   project_name                   = var.project_name
#   documentdb_engine              = "docdb"
#   documentdb_user                = "documentdb"
#   documentdb_password            = "documentdb"
#   documentdb_port                = 27017
#   documentdb_instance_count      = 1
#   documentdb_instance_class      = "db.t3.medium"
#   documentdb_skip_final_snapshot = true
#   documentdb_disable_tls         = true
#   subnet_ids                     = module.vpc.private_subnets_ids[*]
#   vpc_security_group_ids         = [aws_security_group.document_db_sg.id]
#   save_to_ssm                    = true
# }

module "dynamodb" {
  source = "../../modules/dynamodb"

  aws_profile           = var.aws_profile
  aws_region_name       = var.aws_region_name
  project_name          = var.project_name
  dynamodb_table_name   = "${var.project_name}-todos"
  dynamodb_billing_mode = "PAY_PER_REQUEST"
  dynamodb_hash_key     = "title"
  dynamodb_table_attributes = [{
    name = "title"
    type = "S"
    },
  ]
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

module "sqs" {
  source = "../../modules/sqs"

  name                      = "main"
  aws_profile               = var.aws_profile
  aws_region_name           = var.aws_region_name
  project_name              = var.project_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
}


module "cognito" {
  source = "../../modules/cognito"

  name            = "main"
  aws_profile     = var.aws_profile
  aws_region_name = var.aws_region_name
  project_name    = var.project_name
  cognito_user_pool_password_policy = {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  cognito_user_pool_verified_attributes          = ["email"]
  cognito_user_pool_email_verification_subject   = "Your verification code"
  cognito_user_pool_email_verification_message   = "Your verification code is {####}"
  cognito_user_pool_default_email_option         = "CONFIRM_WITH_CODE"
  cognito_user_pool_mfa_configuration            = "OFF"
  cognito_user_pool_allow_admin_create_user_only = false
  cognito_user_pool_account_recovery = {
    name     = "verified_email"
    priority = 1
  }
  cognito_user_pool_schemas = [{
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
    },
    {
      name                = "name"
      attribute_data_type = "String"
      mutable             = true
      required            = true
    },
    {
      name                = "role"
      attribute_data_type = "String"
      mutable             = true
      required            = false
    }
  ]
  cognito_user_pool_client_generate_secret = false
  cognito_user_pool_client_explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  cognito_user_pool_client_refresh_token_validity        = 30
  cognito_user_pool_client_access_token_validity         = 24
  cognito_user_pool_client_id_token_validity             = 24
  cognito_user_pool_client_prevent_user_existence_errors = "ENABLED"
  cognito_user_pool_client_enable_token_revocation       = true

  save_to_ssm = true
}

# module "ecs" {
#   source = "../../modules/ecs"

#   name               = "main"
#   aws_profile        = var.aws_profile
#   aws_region_name    = var.aws_region_name
#   project_name       = var.project_name
#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnets_ids[*]
#   public_subnet_ids  = module.vpc.public_subnets_ids[*]
# }
