# SSM Parameters for app names
resource "aws_ssm_parameter" "app1_name" {
  name  = "/app1/name"
  type  = "String"
  value = "app1"
}

resource "aws_ssm_parameter" "app2_name" {
  name  = "/app2/name"
  type  = "String"
  value = "app2"
}

resource "aws_ssm_parameter" "aws_region_name" {
  name  = "/general/aws-region-name"
  type  = "String"
  value = "us-east-1"
}

resource "aws_ssm_parameter" "cognito_app_client_id" {
  name  = "/cognito/cognito_app_client_id"
  type  = "String"
  value = aws_cognito_user_pool_client.main.id
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/cognito/cognito_app_pool_id"
  type  = "String"
  value = aws_cognito_user_pool.main.id
}
