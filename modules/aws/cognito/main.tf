terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool-${var.name}"

  password_policy {
    minimum_length    = var.cognito_user_pool_password_policy.minimum_length
    require_lowercase = var.cognito_user_pool_password_policy.require_lowercase
    require_numbers   = var.cognito_user_pool_password_policy.require_numbers
    require_symbols   = var.cognito_user_pool_password_policy.require_symbols
    require_uppercase = var.cognito_user_pool_password_policy.require_uppercase
  }

  auto_verified_attributes = var.cognito_user_pool_verified_attributes

  email_verification_subject = var.cognito_user_pool_email_verification_subject
  email_verification_message = var.cognito_user_pool_email_verification_message

  verification_message_template {
    default_email_option = var.cognito_user_pool_default_email_option
  }

  mfa_configuration = var.cognito_user_pool_mfa_configuration

  admin_create_user_config {
    allow_admin_create_user_only = var.cognito_user_pool_allow_admin_create_user_only
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = var.cognito_user_pool_account_recovery.name
      priority = var.cognito_user_pool_account_recovery.priority
    }
  }

  dynamic "schema" {
    for_each = var.cognito_user_pool_schemas
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
      required            = schema.value.required
    }
  }
  lifecycle {
    ignore_changes = [
      schema,
    ]
  }

}

resource "aws_cognito_user_pool_client" "main" {
  name                          = "${var.project_name}-pool-client-${var.name}"
  user_pool_id                  = aws_cognito_user_pool.main.id
  generate_secret               = var.cognito_user_pool_client_generate_secret
  explicit_auth_flows           = var.cognito_user_pool_client_explicit_auth_flows
  refresh_token_validity        = var.cognito_user_pool_client_refresh_token_validity
  access_token_validity         = var.cognito_user_pool_client_access_token_validity
  id_token_validity             = var.cognito_user_pool_client_id_token_validity
  prevent_user_existence_errors = var.cognito_user_pool_client_prevent_user_existence_errors
  enable_token_revocation       = var.cognito_user_pool_client_enable_token_revocation
  write_attributes              = var.cognito_user_pool_client_write_attributes
  read_attributes               = var.cognito_user_pool_client_read_attributes
}
