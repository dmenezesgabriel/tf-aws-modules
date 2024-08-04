output "alb_url" {
  value = aws_lb.main.dns_name
}

output "aws_ecr_repository_apps" {
  value = { for k, v in data.aws_ecr_repository.apps : k => v.repository_url }
}
