terraform {
  required_version = "~> 1.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_iam_policy_document" "role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "iam_role_${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.role.json
}

resource "aws_iam_policy" "main" {
  name   = "iam_policy_${var.function_name}"
  policy = var.function_policy_json
}

resource "aws_iam_role_policy_attachment" "role" {
  role       = aws_iam_role.main.name
  policy_arn = var.lambda_policy_arn

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn

}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = aws_iam_role.main.arn
  memory_size   = var.function_memory_size
  timeout       = var.function_timeout
  image_uri     = var.function_image_uri
  package_type  = "Image"


  ephemeral_storage {
    size = var.function_ephemeral_storage
  }

  environment {
    variables = var.lambda_function_environment_variables
  }

  tracing_config {
    mode = var.lambda_function_tracing_config_mode
  }
}

resource "aws_lambda_function_url" "main" {
  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.lambda_function_url_authroization_type
}
