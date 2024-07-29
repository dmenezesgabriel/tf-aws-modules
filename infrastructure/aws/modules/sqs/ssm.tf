resource "aws_ssm_parameter" "queue_url" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/sqs/queue/${var.name}"
  type  = "String"
  value = aws_sqs_queue.main.name
}
