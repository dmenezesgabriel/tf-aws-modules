variable "region" {
  description = "AWS region"
  type        = string
}

variable "lambda_policy_arn" {
  description = "ARN of the IAM role policy to attach to the lambda role."
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "function_policy_json" {
  description = "Lambda function policy json"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "function_layers" {
  description = "Lambda function layers arns"
  type        = list(string)
  default     = []

}

variable "function_handler" {
  description = "Lambda function handler"
  type        = string
}

variable "function_source_file_path" {
  description = "Lambda function source file path"
  type        = string
}

variable "function_zip_file_path" {
  description = "Lambda function zip file path"
  type        = string
}

variable "function_archive_file_type" {
  description = "Lambda function archive file type"
  type        = string
  default     = "zip"
}

variable "function_runtime" {
  description = "Lambda function runtime"
  type        = string
}

variable "function_memory_size" {
  description = "Lambda function memory size"
  type        = number
  default     = 128
}

variable "function_timeout" {
  description = "Lambda function timeout"
  type        = number
  default     = 3
}

variable "function_ephemeral_storage" {
  description = "Lambda function ephemeral storage"
  type        = number
  default     = 512
}

variable "lambda_function_environment_variables" {
  description = "Lambda function environment variables"
  type        = map(string)
}

variable "lambda_function_tracing_config_mode" {
  description = "Lambda function tracing config mode"
  type        = string
  default     = "Active"
}

variable "lambda_function_url_authroization_type" {
  description = "Lambda function authorization_type"
  type        = string
  default     = "NONE"
}
