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

variable "rds_instance_db_name" {
  type    = string
  default = "postgres"
}

variable "rds_instance_user" {
  type    = string
  default = "postgres"
}

variable "rds_instance_password" {
  type    = string
  default = "postgres"
}

variable "rds_instance_port" {
  type    = string
  default = "5432"
}
