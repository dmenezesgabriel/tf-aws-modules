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

variable "documentdb_user" {
  type    = string
  default = "documentdb"
}

variable "documentdb_password" {
  type    = string
  default = "documentdb"
}

variable "documentdb_port" {
  type    = string
  default = "27017"
}
