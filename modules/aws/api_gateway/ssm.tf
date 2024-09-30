resource "aws_ssm_parameter" "cognito_user_pool_client_id" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/apigateway/${var.api_gateway_name}/invoke_url"
  type  = "String"
  value = aws_apigatewayv2_api.main.api_endpoint
}
