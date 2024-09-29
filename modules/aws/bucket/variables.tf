variable "bucket_name" {
  description = "Bucket name"
  type        = string
}

variable "bucket_tags" {
  type    = object({})
  default = {}
}
