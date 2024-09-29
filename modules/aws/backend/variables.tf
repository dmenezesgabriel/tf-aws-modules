variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}


variable "kms_alias_name" {
  type    = string
  default = null
}

variable "bucket_server_side_encryption_enabled" {
  type    = bool
  default = false
}
