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

variable "image_tag" {
  type = string
}

variable "ecs_repository_name" {
  type = string
}
