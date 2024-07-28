resource "aws_ssm_parameter" "rds_instance_endpoint" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_endpoint_url"
  type  = "String"
  value = aws_db_instance.main.endpoint
}

resource "aws_ssm_parameter" "rds_instance_host" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_host"
  type  = "String"
  value = element(split(":", aws_db_instance.main.endpoint), 0)
}

resource "aws_ssm_parameter" "rds_instance_port" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_port"
  type  = "String"
  value = var.rds_instance_port
}

resource "aws_ssm_parameter" "rds_instance_db_name" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_db_name"
  type  = "String"
  value = var.rds_instance_db_name
}

resource "aws_ssm_parameter" "rds_instance_user" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_user"
  type  = "String"
  value = var.rds_instance_user
}

resource "aws_ssm_parameter" "rds_instance_password" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/rds/postgres/rds_instance_password"
  type  = "String"
  value = var.rds_instance_password
}
