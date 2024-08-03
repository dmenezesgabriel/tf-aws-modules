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
data "aws_ecr_repository" "main" {
  name = var.ecs_repository_name
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
  policy      = var.batch_policy
}

resource "aws_iam_role_policy_attachment" "batch_service_main" {
  role       = aws_iam_role.batch_service.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_batch_compute_environment" "main" {
  compute_environment_name = "${var.project_name}-${var.name}"
  type                     = "MANAGED"
  service_role             = aws_iam_role.batch_service.arn

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 2
    subnets            = var.compute_resource_subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_iam_role" "batch_execution" {
  name = "${var.project_name}-batch-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_execution_policy" {
  role       = aws_iam_role.batch_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_batch_job_definition" "main" {
  name = "${var.project_name}-${var.name}-batch-job-definition"
  type = "container"

  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    platform_version = "LATEST"
    image            = "${data.aws_ecr_repository.main.repository_url}:${var.image_tag}"
    jobRoleArn       = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    resourceRequirements = [
      {
        type  = "VCPU"
        value = "2"
      },
      {
        type  = "MEMORY"
        value = "4096"
      }
    ]
    command     = var.command
    environment = var.environment
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/batch/${var.project_name}/${var.name}/logs"
        "awslogs-region"        = var.aws_region_name
        "awslogs-stream-prefix" = "batch"
      }
    }
    executionRoleArn = aws_iam_role.batch_execution.arn
  })
}

resource "aws_batch_job_queue" "main" {
  name                 = "${var.project_name}-batch-${var.name}-job-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.main.arn]
}

resource "aws_cloudwatch_log_group" "batch_log_group" {
  name              = "/aws/batch/${var.project_name}/${var.name}/logs"
  retention_in_days = 7
}
