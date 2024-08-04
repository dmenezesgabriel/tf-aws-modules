output "queue_url" {
  description = "The URL for the created Amazon SQS queue."
  value       = aws_sqs_queue.main.id
}

