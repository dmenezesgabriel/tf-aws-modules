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
  default = "todo-microservices"
}

variable "name" {
  type = string
}

variable "documentdb_engine" {
  type    = string
  default = "docdb"
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

variable "documentdb_family" {
  type    = string
  default = "docdb5.0"
}

variable "documentdb_instance_count" {
  type    = number
  default = 1
}

variable "documentdb_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "documentdb_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "documentdb_disable_tls" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "save_to_ssm" {
  type    = bool
  default = true
}
