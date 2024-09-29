aws_region_name             = "us-east-1"
project_name                = "cognito-api"
aws_access_key              = "test"
aws_secret_key              = "test"
s3_use_path_style           = false
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_requesting_account_id  = true

aws_service_endpoints = {
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