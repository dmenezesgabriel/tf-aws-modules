variable "aws_region_name" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "project_name" {
  type    = string
  default = "todo-microsservices"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}
