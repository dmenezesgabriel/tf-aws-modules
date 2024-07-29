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

variable "rds_instance_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_instance_engine" {
  type    = string
  default = "postgres"
}

variable "rds_instance_engine_version" {
  type    = string
  default = "16.3"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
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

variable "rds_instance_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "rds_instance_publicly_accessible" {
  type    = bool
  default = false
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "save_to_ssm" {
  type    = bool
  default = true
}
