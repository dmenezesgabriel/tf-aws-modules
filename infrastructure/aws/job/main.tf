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

data "aws_ecr_repository" "main" {
  name = "ecs-todo-command"
}

resource "aws_security_group" "batch" {
  name   = "${var.project_name}-batch-security-group"
  vpc_id = data.aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "batch_service" {
  name = "batch_service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_service" {
  role       = aws_iam_role.batch_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}


resource "aws_iam_policy" "main" {
  name        = "${var.project_name}-batch-policy"
  description = "Policy to allow access to RDS, SSM, and CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.batch_log_group.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_service_main" {
  role       = aws_iam_role.batch_service.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_batch_compute_environment" "main" {
  compute_environment_name = "${var.project_name}-batch-alembic-migration"
  type                     = "MANAGED"
  service_role             = aws_iam_role.batch_service.arn

  compute_resources {
    type               = "FARGATE"
    min_vcpus          = 0
    max_vcpus          = 2
    desired_vcpus      = 1
    subnets            = data.aws_subnets.private.ids[*]
    security_group_ids = [aws_security_group.batch.id]
  }
}


resource "aws_batch_job_definition" "main" {
  name = "${var.project_name}-batch-job-definition"
  type = "container"

  container_properties = jsonencode({
    platform_version = "LATEST"
    image            = "${data.aws_ecr_repository.main.repository_url}:20240721220624"
    vcpus            = 2
    memory           = 4096
    command          = ["bash", "-c", "'alembic -c migrations/alembic/alembic.ini upgrade head'"]
    environment = [
      {
        name  = "DATABASE_HOST"
        value = data.aws_ssm_parameter.rds_instance_host.value
      },
      {
        name  = "DATABASE_PORT"
        value = data.aws_ssm_parameter.rds_instance_port.value
      },
      {
        name  = "DATABASE_USER"
        value = data.aws_ssm_parameter.rds_instance_user.value
      },
      {
        name  = "DATABASE_PASSWORD"
        value = data.aws_ssm_parameter.rds_instance_password.value
      },
      {
        name  = "DATABASE_DB_NAME"
        value = data.aws_ssm_parameter.rds_instance_db_name.value
      },
      {
        name  = "AWS_REGION_NAME",
        value = var.aws_region_name
      }

    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/batch/${var.project_name}/logs"
        "awslogs-region"        = var.aws_region_name
        "awslogs-stream-prefix" = "batch"
      }
    }
  })
}

resource "aws_batch_job_queue" "main" {
  name                 = "${var.project_name}-batch-job-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.main.arn]
}

resource "aws_cloudwatch_log_group" "batch_log_group" {
  name              = "/aws/batch/${var.project_name}/logs"
  retention_in_days = 7
}
