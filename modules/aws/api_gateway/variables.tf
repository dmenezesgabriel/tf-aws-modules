variable "api_gateway_name" {
  description = "API gateway name"
  type        = string
}

variable "api_gateway_protocol_type" {
  description = "API gateway protocol type"
  type        = string
}

variable "api_gateway_body" {
  description = "API gateway body"
  type        = string
}

variable "api_gateway_cors_configuration" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api#cors_configuration"
  type = list(object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age           = number
  }))
  default = []
}

variable "api_gateway_stage" {
  description = "API gateway stage"
  type        = string
}

variable "api_gateway_access_log_settings" {
  type = object({
    format            = string
    retention_in_days = number
  })
  default = {
    format            = "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
    retention_in_days = 90
  }
  description = "https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#apigateway-cloudwatch-log-formats"
}
