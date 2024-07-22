resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/${var.project_name}/rds/postgres/endpoint_url"
  type  = "String"
  value = aws_db_instance.main.endpoint
}

resource "aws_ssm_parameter" "rds_instance_port" {
  name  = "/${var.project_name}/rds/postgres/rds_instance_port"
  type  = "String"
  value = var.rds_instance_port
}

resource "aws_ssm_parameter" "rds_instance_db_name" {
  name  = "/${var.project_name}/rds/postgres/rds_instance_db_name"
  type  = "String"
  value = var.rds_instance_db_name
}

resource "aws_ssm_parameter" "rds_instance_user" {
  name  = "/${var.project_name}/rds/postgres/rds_instance_user"
  type  = "String"
  value = var.rds_instance_user
}

resource "aws_ssm_parameter" "rds_instance_password" {
  name  = "/${var.project_name}/rds/postgres/rds_instance_password"
  type  = "String"
  value = var.rds_instance_password
}
