output "rds_instance_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_instance_host" {
  value = element(split(":", aws_db_instance.main.endpoint), 0)
}

output "rds_instance_port" {
  value = var.rds_instance_port
}

output "rds_instance_db_name" {
  value = var.rds_instance_db_name
}

output "rds_instance_user" {
  value = var.rds_instance_user
}

output "rds_instance_password" {
  value = var.rds_instance_password
}
