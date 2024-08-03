variable "aws_region_name" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "project_name" {
  type = string
}

variable "name" {
  type = string
}

variable "cognito_user_pool_password_policy" {
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
  default = {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

variable "cognito_user_pool_verified_attributes" {
  type    = list(string)
  default = ["email"]
}

variable "cognito_user_pool_email_verification_subject" {
  type    = string
  default = "Your verification code"
}

variable "cognito_user_pool_email_verification_message" {
  type    = string
  default = "Your verification code is {####}"
}

variable "cognito_user_pool_default_email_option" {
  type    = string
  default = "CONFIRM_WITH_CODE"
}

variable "cognito_user_pool_mfa_configuration" {
  type    = string
  default = "OFF"
}

variable "cognito_user_pool_allow_admin_create_user_only" {
  type    = bool
  default = false
}

variable "cognito_user_pool_account_recovery" {
  type = object({
    name     = string
    priority = number
  })
  default = {
    name     = "verified_email"
    priority = 1
  }

}

variable "cognito_user_pool_schemas" {
  type = list(object({
    name                = string
    attribute_data_type = string
    mutable             = bool
    required            = bool
  }))
  default = [{
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
    },
    {
      name                = "name"
      attribute_data_type = "String"
      mutable             = true
      required            = true
    },
    {
      name                = "role"
      attribute_data_type = "String"
      mutable             = true
      required            = false
    }
  ]
}

variable "cognito_user_pool_client_generate_secret" {
  type    = bool
  default = false
}

variable "cognito_user_pool_client_explicit_auth_flows" {
  type = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

variable "cognito_user_pool_client_refresh_token_validity" {
  type    = number
  default = 30
}

variable "cognito_user_pool_client_access_token_validity" {
  type    = number
  default = 24
}
variable "cognito_user_pool_client_id_token_validity" {
  type    = number
  default = 24
}

variable "cognito_user_pool_client_prevent_user_existence_errors" {
  type    = string
  default = "ENABLED"
}

variable "cognito_user_pool_client_enable_token_revocation" {
  type    = bool
  default = true
}

variable "save_to_ssm" {
  type    = bool
  default = true
}
