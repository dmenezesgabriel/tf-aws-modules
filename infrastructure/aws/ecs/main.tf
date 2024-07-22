terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "5.17.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}


data "aws_vpc" "main" {
  tags = { Name = "${var.project_name}-vpc" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_security_group" "ecs_task" {
  name = "${var.project_name}-ecs-task-sg"
}

data "aws_security_group" "ecs_node_sg" {
  name = "${var.project_name}-ecs-node-sg"
}

# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
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
  name_prefix        = "${var.project_name}-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "${var.project_name}-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}


# --- ECS Launch Template ---

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "${var.project_name}-ecs-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [data.aws_security_group.ecs_node_sg.id]

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
  vpc_zone_identifier       = data.aws_subnets.private.ids[*]
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-cluster"
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
  name = "${var.project_name}-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}

# --- ECS Task policies ---
data "aws_iam_policy_document" "ecs_access_policy_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBClusterSnapshots"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "cognito-idp:SignUp",
      "cognito-idp:ConfirmSignUp",
      "cognito-idp:ResendConfirmationCode",
      "cognito-idp:AdminGetUser",
      "cognito-idp:InitiateAuth",
      "cognito-idp:ForgotPassword",
      "cognito-idp:ConfirmForgotPassword",
      "cognito-idp:ChangePassword",
      "cognito-idp:GlobalSignOut"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:ExecuteCommand"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_access_policy" {
  name   = "ecs-task-ssm-policy"
  role   = aws_iam_role.ecs_task_role.name
  policy = data.aws_iam_policy_document.ecs_access_policy_doc.json
}

resource "aws_iam_role_policy" "ecs_exec_access_policy" {
  name   = "ecs-exec-ssm-policy"
  role   = aws_iam_role.ecs_exec_role.name
  policy = data.aws_iam_policy_document.ecs_access_policy_doc.json
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
  name_prefix        = "${var.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "${var.project_name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Cloud Watch Logs ---

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

# --- ECR Repository ---
data "aws_ecr_repository" "apps" {
  for_each = var.applications
  name     = each.value.aws_ecr_repository_name
}

output "aws_ecr_repository_apps" {
  value = { for k, v in data.aws_ecr_repository.apps : k => v.repository_url }
}

# --- ECS Task Definition ---
data "aws_ssm_parameter" "rds_instance_host" {
  name = "/${var.project_name}/rds/postgres/rds_instance_host"
}

data "aws_ssm_parameter" "rds_instance_port" {
  name = "/${var.project_name}/rds/postgres/rds_instance_port"
}

data "aws_ssm_parameter" "rds_instance_db_name" {
  name = "/${var.project_name}/rds/postgres/rds_instance_db_name"
}

data "aws_ssm_parameter" "rds_instance_user" {
  name = "/${var.project_name}/rds/postgres/rds_instance_user"
}

data "aws_ssm_parameter" "rds_instance_password" {
  name = "/${var.project_name}/rds/postgres/rds_instance_password"
}

data "aws_ssm_parameter" "cognito_app_client_id" {
  name = "/${var.project_name}/cognito/cognito_app_client_id"
}

data "aws_ssm_parameter" "cognito_app_pool_id" {
  name = "/${var.project_name}/cognito/cognito_app_pool_id"
}

data "aws_ecr_repository" "main" {
  name = "ecs-todo-command"
}

resource "aws_ecs_task_definition" "apps" {
  for_each           = var.applications
  family             = "${var.project_name}-${each.key}"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 256

  container_definitions = jsonencode([{
    name         = each.value.name,
    image        = "${data.aws_ecr_repository.apps[each.key].repository_url}:${each.value.image_tag}",
    essential    = true,
    portMappings = [{ containerPort = each.value.port, hostPort = each.value.port }],
    secrets = [
      {
        name      = "AWS_COGNITO_APP_CLIENT_ID"
        valueFrom = data.aws_ssm_parameter.cognito_app_client_id.arn
      },
      {
        name      = "AWS_COGNITO_USER_POOL_ID"
        valueFrom = data.aws_ssm_parameter.cognito_app_pool_id.arn
      },
      {
        name      = "DATABASE_HOST"
        valueFrom = data.aws_ssm_parameter.rds_instance_host.arn
      },
      {
        name      = "DATABASE_PORT"
        valueFrom = data.aws_ssm_parameter.rds_instance_port.arn
      },
      {
        name      = "DATABASE_DB_NAME"
        valueFrom = data.aws_ssm_parameter.rds_instance_db_name.arn
      },
      {
        name      = "DATABASE_USER"
        valueFrom = data.aws_ssm_parameter.rds_instance_user.arn
      },
      {
        name      = "DATABASE_PASSWORD"
        valueFrom = data.aws_ssm_parameter.rds_instance_password.arn
      },
    ]

    environment = [
      { name = "AWS_REGION_NAME", value = var.aws_region_name }
    ]

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
  for_each               = var.applications
  name                   = each.value.name
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.apps[each.key].arn
  desired_count          = 2
  enable_execute_command = true

  depends_on = [aws_lb_target_group.apps, aws_lb_listener_rule.apps]

  load_balancer {
    target_group_arn = aws_lb_target_group.apps[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.port
  }

  network_configuration {
    security_groups = [data.aws_security_group.ecs_task.id]
    subnets         = data.aws_subnets.private.ids[*]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
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

resource "aws_security_group" "http" {
  name_prefix = "${var.project_name}-http-sg-"
  description = "Allow all HTTP/HTTPS traffic from public"
  vpc_id      = data.aws_vpc.main.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids[*]
  security_groups    = [aws_security_group.http.id]
}

resource "aws_lb_target_group" "apps" {
  for_each    = var.applications
  name        = each.value.name
  vpc_id      = data.aws_vpc.main.id
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
  for_each     = var.applications
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


output "alb_url" {
  value = aws_lb.main.dns_name
}

# --- ECS Service Auto Scaling app 1---

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = var.applications
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.apps[each.key].name}"
  min_capacity       = 2
  max_capacity       = 5
}

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  for_each           = var.applications
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
  for_each           = var.applications
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
