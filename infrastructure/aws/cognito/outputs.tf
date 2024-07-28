output "cognito_app_client_id" {
  value = aws_cognito_user_pool_client.main.id
}
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}
