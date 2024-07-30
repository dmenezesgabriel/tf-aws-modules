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

variable "vpc_id" {
  type = string
}

variable "services_subnet_ids" {
  type = list(string)
}

variable "load_balancer_subnet_ids" {
  type = list(string)
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "services" {
  type = map(object({
    name                       = string
    aws_ecr_repository_name    = string
    image_tag                  = string
    port                       = number
    path                       = string
    health_path                = string
    task_role_policy           = map(string)
    task_execution_role_policy = map(string)
    network_mode               = string
    cpu                        = number
    memory                     = number
    desired_count              = number
    enable_execute_command     = bool
    environment = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "autoscaling_group_min_size" {
  type    = number
  default = 2
}

variable "autoscaling_group_max_size" {
  type    = number
  default = 4
}

variable "autoscaling_group_health_check_grace_period" {
  type    = number
  default = 0
}

variable "autoscaling_group_health_check_type" {
  type    = string
  default = "EC2"
}

variable "autoscaling_group_protect_from_scale_in" {
  type    = bool
  default = false
}

variable "auto_scaling_group_termination_protection" {
  type    = string
  default = false
}

variable "auto_scaling_group_maximum_scaling_step_size" {
  type    = number
  default = 2
}

variable "auto_scaling_group_minimum_scaling_step_size" {
  type    = number
  default = 1
}


variable "auto_scaling_group_managed_scaling_status" {
  type    = string
  default = "ENABLED"
}


variable "auto_scaling_group_managed_scaling_target_capacity" {
  type    = number
  default = 100
}

variable "default_capacity_provider_strategy_base" {
  type    = number
  default = 1
}
variable "default_capacity_provider_strategy_weight" {
  type    = number
  default = 100
}

variable "load_balancer_security_group_id" {
  type = string
}
