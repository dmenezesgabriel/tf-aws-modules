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

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "dynamodb_hash_key" {
  type    = string
  default = null
}

variable "dynamodb_range_key" {
  type    = string
  default = null
}

variable "dynamodb_ttl_attribute_name" {
  type    = string
  default = "TimeToExist"
}

variable "dynamodb_ttl_enabled" {
  type    = bool
  default = false
}


variable "dynamodb_table_attributes" {
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
    }
  ))
  default = []
}
