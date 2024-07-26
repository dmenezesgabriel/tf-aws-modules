resource "aws_ssm_parameter" "documentdb_user" {
  name  = "/${var.project_name}/documentdb/documentdb_user"
  type  = "String"
  value = var.documentdb_user
}

resource "aws_ssm_parameter" "documentdb_password" {
  name  = "/${var.project_name}/documentdb/documentdb_password"
  type  = "String"
  value = var.documentdb_password
}

resource "aws_ssm_parameter" "documentdb_endpoint" {
  name  = "/${var.project_name}/documentdb/documentdb_endpoint"
  type  = "String"
  value = aws_docdb_cluster.main.endpoint
}

resource "aws_ssm_parameter" "documentdb_port" {
  name  = "/${var.project_name}/documentdb/documentdb_port"
  type  = "String"
  value = var.documentdb_port
}
