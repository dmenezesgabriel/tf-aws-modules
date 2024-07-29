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

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "applications" {
  type = map(object({
    name                    = string
    aws_ecr_repository_name = string
    image_tag               = string
    port                    = number
    path                    = string
    health_path             = string

  }))
  default = {
    auth = {
      name                    = "auth"
      aws_ecr_repository_name = "ecs-todo-auth"
      image_tag               = "latest"
      port                    = 80
      path                    = "/auth/"
      health_path             = "/auth/"

    }
    command = {
      name                    = "command"
      aws_ecr_repository_name = "ecs-todo-command"
      image_tag               = "latest"
      port                    = 80
      path                    = "/command/"
      health_path             = "/command/"
    }
  }
}
