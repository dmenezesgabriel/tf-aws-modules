# SSM Parameters for app names
resource "aws_ssm_parameter" "app1_name" {
  name  = "/app1/name"
  type  = "String"
  value = "app1"
}

resource "aws_ssm_parameter" "app2_name" {
  name  = "/app2/name"
  type  = "String"
  value = "app2"
}
