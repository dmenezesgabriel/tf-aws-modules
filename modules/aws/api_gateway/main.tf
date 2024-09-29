terraform {
  required_version = "~> 1.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/apigateway/${aws_apigatewayv2_api.main.name}"
}

resource "aws_apigatewayv2_api" "main" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_protocol_type
  body          = var.api_gateway_body
  version       = sha256(var.api_gateway_body)

  dynamic "cors_configuration" {
    for_each = var.api_gateway_cors_configuration
    content {
      allow_credentials = cors_configuration.value["allow_credentials"]
      allow_headers     = cors_configuration.value["allow_headers"]
      allow_methods     = cors_configuration.value["allow_methods"]
      allow_origins     = cors_configuration.value["allow_origins"]
      expose_headers    = cors_configuration.value["expose_headers"]
      max_age           = cors_configuration.value["max_age"]
    }
  }
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id

  triggers = {
    "redeployment" = sha256(var.api_gateway_body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "main" {
  api_id        = aws_apigatewayv2_api.main.id
  name          = var.api_gateway_stage
  deployment_id = aws_apigatewayv2_deployment.main.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main.arn
    format          = var.api_gateway_access_log_settings.format
  }
}
