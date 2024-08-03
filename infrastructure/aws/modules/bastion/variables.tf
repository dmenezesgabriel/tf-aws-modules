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

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_instance_ami" {
  type = string
}

variable "ec2_instance_connection_type" {
  type    = string
  default = "ssh"
}

variable "ec2_instance_connection_user" {
  type    = string
  default = "ec2-user"
}

variable "save_to_ssm" {
  type    = bool
  default = true
}

variable "provisioner_remote_exec" {
  type    = list(string)
  default = []
}

variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}
