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

resource "aws_ssm_parameter" "cognito_issuer_uri" {
  name  = "/${var.project_name}/cognito/cognito_issuer_uri"
  type  = "String"
  value = "https://cognito-idp.${var.aws_region_name}.amazonaws.com/${aws_cognito_user_pool.main.id}/"
}

resource "aws_ssm_parameter" "cognito_jwk_uri" {
  name  = "/${var.project_name}/cognito/cognito_jwk_uri"
  type  = "String"
  value = "https://cognito-idp.${var.aws_region_name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
}
