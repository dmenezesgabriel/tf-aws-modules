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

variable "image_tag" {
  type = string
}

variable "ecs_repository_name" {
  type = string
}

variable "compute_resource_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "command" {
  type = list(string)
}

variable "batch_policy" {
  type = string
}
