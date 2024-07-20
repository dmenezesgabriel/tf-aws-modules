# --- AWS Cognito ---
resource "aws_cognito_user_pool" "main" {
  name = "demo-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]

  email_verification_subject = "Your verification code"
  email_verification_message = "Your verification code is {####}"

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
  }

  lifecycle {
    ignore_changes = [
      schema,
    ]
  }

}

resource "aws_cognito_user_pool_client" "main" {
  name            = "demo-app-client"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  refresh_token_validity = 30
  access_token_validity  = 24
  id_token_validity      = 24

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true
}

output "cognito_app_client_id" {
  value = aws_cognito_user_pool_client.main.id
}
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}
