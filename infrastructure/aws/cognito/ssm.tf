resource "aws_ssm_parameter" "cognito_app_client_id" {
  name  = "/${var.project_name}/cognito/cognito_app_client_id"
  type  = "String"
  value = aws_cognito_user_pool_client.main.id
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/${var.project_name}/cognito/cognito_app_pool_id"
  type  = "String"
  value = aws_cognito_user_pool.main.id
}
