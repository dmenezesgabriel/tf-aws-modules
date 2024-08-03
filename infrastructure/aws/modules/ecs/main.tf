terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}

# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.name}"
}

# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "${var.project_name}-ecs-${var.name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "${var.project_name}-ecs-${var.name}-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}


# --- ECS Launch Template ---

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "${var.project_name}-ecs-${var.name}-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

# --- ECS ASG ---

resource "aws_autoscaling_group" "ecs" {
  name_prefix               = "${var.project_name}-ecs-asg-"
  vpc_zone_identifier       = var.services_subnet_ids
  min_size                  = var.autoscaling_group_min_size
  max_size                  = var.autoscaling_group_max_size
  health_check_grace_period = var.autoscaling_group_health_check_grace_period
  health_check_type         = var.autoscaling_group_health_check_type
  protect_from_scale_in     = var.autoscaling_group_protect_from_scale_in

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-${var.name}-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# --- ECS Capacity Provider ---

resource "aws_ecs_capacity_provider" "main" {
  name = "${var.project_name}-ecs-${var.name}-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = var.auto_scaling_group_termination_protection

    managed_scaling {
      maximum_scaling_step_size = var.auto_scaling_group_maximum_scaling_step_size
      minimum_scaling_step_size = var.auto_scaling_group_minimum_scaling_step_size
      status                    = var.auto_scaling_group_managed_scaling_status
      target_capacity           = var.auto_scaling_group_managed_scaling_target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = var.default_capacity_provider_strategy_base
    weight            = var.default_capacity_provider_strategy_weight
  }
}

# --- ECS Task Role ---

data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  for_each = var.services

  name_prefix        = "${var.project_name}-${each.key}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_task_exec_role" {
  for_each = var.services

  name_prefix        = "${var.project_name}-${each.key}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy" "ecs_task_access_policy" {
  for_each = var.services

  name   = "${var.project_name}-${each.key}-task-policy"
  role   = aws_iam_role.ecs_task_role[each.key].name
  policy = each.value.task_role_policy
}

resource "aws_iam_role_policy" "ecs_task_exec_access_policy" {
  for_each = var.services

  name   = "${var.project_name}-${each.key}-exec-policy"
  role   = aws_iam_role.ecs_task_exec_role[each.key].name
  policy = each.value.task_execution_role_policy
}


resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy" {
  for_each = var.services

  role       = aws_iam_role.ecs_task_exec_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Cloud Watch Logs ---

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}/${var.name}"
  retention_in_days = 7
}

# --- ECR Repository ---
data "aws_ecr_repository" "apps" {
  for_each = var.services
  name     = each.value.aws_ecr_repository_name
}

# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "apps" {
  for_each           = var.services
  family             = "${var.project_name}-${each.key}"
  task_role_arn      = aws_iam_role.ecs_task_role[each.key].arn
  execution_role_arn = aws_iam_role.ecs_task_exec_role[each.key].arn
  network_mode       = each.value.network_mode
  cpu                = each.value.cpu
  memory             = each.value.memory

  container_definitions = jsonencode([{
    name         = each.value.name,
    image        = "${data.aws_ecr_repository.apps[each.key].repository_url}:${each.value.image_tag}",
    essential    = true,
    portMappings = [{ containerPort = each.value.port, hostPort = each.value.port }],
    environment  = each.value.environment

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = var.aws_region_name,
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name,
        "awslogs-stream-prefix" = each.key
      }
    },
  }])
}


# --- ECS Service ---
resource "aws_ecs_service" "apps" {
  for_each               = var.services
  name                   = each.value.name
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.apps[each.key].arn
  desired_count          = each.value.desired_count
  enable_execute_command = each.value.enable_execute_command

  depends_on = [aws_lb_target_group.apps, aws_lb_listener_rule.apps]

  load_balancer {
    target_group_arn = aws_lb_target_group.apps[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.port
  }

  network_configuration {
    security_groups = var.vpc_security_group_ids
    subnets         = var.services_subnet_ids
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = var.default_capacity_provider_strategy_base
    weight            = var.default_capacity_provider_strategy_weight
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# --- ALB ---

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  subnets            = var.load_balancer_subnet_ids
  security_groups    = var.load_balancer_security_group_id
}

resource "aws_lb_target_group" "apps" {
  for_each    = var.services
  name        = each.value.name
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = each.value.port
  target_type = "ip"

  health_check {
    enabled             = true
    path                = each.value.health_path
    port                = each.value.port
    matcher             = 200
    interval            = 300
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# --- ALB Listeners ---

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

# --- ALB Listeners---

resource "aws_lb_listener_rule" "apps" {
  for_each     = var.services
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apps[each.key].arn
  }

  condition {
    path_pattern {
      values = ["${each.value.path}*"]
    }
  }
}

# --- ECS Service Auto Scaling app 1---

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = var.services
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.apps[each.key].name}"
  min_capacity       = 2
  max_capacity       = 4
}

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  for_each           = var.services
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  for_each           = var.services
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
