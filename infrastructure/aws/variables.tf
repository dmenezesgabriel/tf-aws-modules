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
variable "image_tag" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "applications" {
  type = map(object({
    name                    = string
    aws_ecr_repository_name = string
    port                    = number
    path                    = string
    health_path             = string

  }))
  default = {
    auth = {
      name                    = "auth"
      aws_ecr_repository_name = "ecs-todo-auth"
      port                    = 80
      path                    = "/auth/"
      health_path             = "/auth/"

    }
    command = {
      name                    = "command"
      aws_ecr_repository_name = "ecs-todo-command"
      port                    = 80
      path                    = "/command/"
      health_path             = "/command/"

    }
  }
}

variable "db_instance_credentials" {
  type = object({
    db_name  = string
    username = string
    password = string
  })
  default = {
    db_name  = "postgres"
    username = "postgres"
    password = "postgres"
  }
}
