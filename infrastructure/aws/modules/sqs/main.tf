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

resource "aws_sqs_queue" "main" {
  name                      = var.sqs_queue_name
  delay_seconds             = var.sqs_queue_delay_seconds
  max_message_size          = var.sqs_queue_max_message_size
  message_retention_seconds = var.sqs_queue_message_retention_seconds
  receive_wait_time_seconds = var.sqs_queue_receive_wait_time_seconds
  tags = {
    Name = "${var.project_name}-sqs-queue-${var.sqs_queue_name}"
  }
}
