output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "cognito_jwk_uri" {
  value = "https://cognito-idp.${var.aws_region_name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
}

output "cognito_issuer_uri" {
  value = "https://cognito-idp.${var.aws_region_name}.amazonaws.com/${aws_cognito_user_pool.main.id}/"
}
