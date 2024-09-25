terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region_name
  access_key = "test"
  secret_key = "test"

  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true


  endpoints {
    apigateway     = "http://motoserver:4566"
    apigatewayv2   = "http://motoserver:4566"
    cloudformation = "http://motoserver:4566"
    cloudwatch     = "http://motoserver:4566"
    cognitoidp     = "http://motoserver:4566"
    dynamodb       = "http://motoserver:4566"
    ec2            = "http://motoserver:4566"
    es             = "http://motoserver:4566"
    elasticache    = "http://motoserver:4566"
    firehose       = "http://motoserver:4566"
    iam            = "http://motoserver:4566"
    kinesis        = "http://motoserver:4566"
    lambda         = "http://motoserver:4566"
    rds            = "http://motoserver:4566"
    redshift       = "http://motoserver:4566"
    route53        = "http://motoserver:4566"
    s3             = "http://s3.motoserver.localstack.cloud:4566"
    secretsmanager = "http://motoserver:4566"
    ses            = "http://motoserver:4566"
    sns            = "http://motoserver:4566"
    sqs            = "http://motoserver:4566"
    ssm            = "http://motoserver:4566"
    stepfunctions  = "http://motoserver:4566"
    sts            = "http://motoserver:4566"
  }
}

module "cognito" {
  source = "github.com/dmenezesgabriel/tf-aws-modules//modules/aws/cognito"

  name            = "main"
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
  cognito_user_pool_client_write_attributes              = ["email", "name", "role"]
  cognito_user_pool_client_read_attributes               = ["sub", "email", "name", "role"]
  save_to_ssm                                            = true
}
