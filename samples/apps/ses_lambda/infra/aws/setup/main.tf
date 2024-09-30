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
  profile    = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  s3_use_path_style           = var.s3_use_path_style
  skip_credentials_validation = var.skip_credentials_validation
  skip_metadata_api_check     = var.skip_metadata_api_check
  skip_requesting_account_id  = var.skip_requesting_account_id


  endpoints {
    apigateway     = var.aws_service_endpoints["apigateway"]
    apigatewayv2   = var.aws_service_endpoints["apigatewayv2"]
    cloudformation = var.aws_service_endpoints["cloudformation"]
    cloudwatch     = var.aws_service_endpoints["cloudwatch"]
    cognitoidp     = var.aws_service_endpoints["cognitoidp"]
    dynamodb       = var.aws_service_endpoints["dynamodb"]
    ec2            = var.aws_service_endpoints["ec2"]
    es             = var.aws_service_endpoints["es"]
    elasticache    = var.aws_service_endpoints["elasticache"]
    firehose       = var.aws_service_endpoints["firehose"]
    iam            = var.aws_service_endpoints["iam"]
    kinesis        = var.aws_service_endpoints["kinesis"]
    lambda         = var.aws_service_endpoints["lambda"]
    rds            = var.aws_service_endpoints["rds"]
    redshift       = var.aws_service_endpoints["redshift"]
    route53        = var.aws_service_endpoints["route53"]
    s3             = var.aws_service_endpoints["s3"]
    secretsmanager = var.aws_service_endpoints["secretsmanager"]
    ses            = var.aws_service_endpoints["ses"]
    sns            = var.aws_service_endpoints["sns"]
    sqs            = var.aws_service_endpoints["sqs"]
    ssm            = var.aws_service_endpoints["ssm"]
    stepfunctions  = var.aws_service_endpoints["stepfunctions"]
    sts            = var.aws_service_endpoints["sts"]
  }
}

module "ses_lambda" {
  source = "github.com/dmenezesgabriel/tf-aws-modules//modules/aws/lambda"

  region                    = var.aws_region_name
  function_policy_json      = data.aws_iam_policy_document.lambda_ses.json
  function_name             = "ses_lambda"
  function_handler          = "lambda_function.lambda_handler"
  function_source_file_path = abspath("${path.module}/../../../src/lambda_function.py")
  function_zip_file_path    = abspath("${path.module}/../../../src/lambda_function.zip")
  function_runtime          = "python3.11"
  function_memory_size      = 128
  function_timeout          = 15
  lambda_function_environment_variables = {
    AWS_REGION_NAME = var.aws_region_name
  }
}

resource "aws_lambda_permission" "athena_lambda_allow_apigateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.ses_lambda.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

module "api_gateway" {
  source                    = "github.com/dmenezesgabriel/tf-aws-modules//modules/aws/api_gateway"
  api_gateway_name          = "ses_api"
  api_gateway_stage         = "dev"
  api_gateway_protocol_type = "HTTP"
  api_gateway_body = templatefile(abspath("${path.module}/../../../api.yaml"),
    {
      ses_lambda_arn = "${module.ses_lambda.lambda_function.invoke_arn}"
      region         = var.aws_region_name
    }
  )
}
