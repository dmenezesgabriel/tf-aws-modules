resource "aws_ssm_parameter" "queue_url" {
  name  = "/${var.project_name}/sqs/queue/${var.name}"
  type  = string
  value = aws_sqs_queue.main.id
}

