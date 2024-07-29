resource "aws_ssm_parameter" "documentdb_user" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/documentdb/${var.name}/documentdb_user"
  type  = "String"
  value = var.documentdb_user
}

resource "aws_ssm_parameter" "documentdb_password" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/documentdb/${var.name}/documentdb_password"
  type  = "String"
  value = var.documentdb_password
}

resource "aws_ssm_parameter" "documentdb_endpoint" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/documentdb/${var.name}/documentdb_endpoint"
  type  = "String"
  value = aws_docdb_cluster.main.endpoint
}

resource "aws_ssm_parameter" "documentdb_port" {
  count = var.save_to_ssm ? 1 : 0

  name  = "/${var.project_name}/documentdb/${var.name}/documentdb_port"
  type  = "String"
  value = var.documentdb_port
}
