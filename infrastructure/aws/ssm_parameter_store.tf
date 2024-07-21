# SSM Parameters for app names
resource "aws_ssm_parameter" "aws_region_name" {
  name  = "/general/aws-region-name"
  type  = "String"
  value = "us-east-1"
}

resource "aws_ssm_parameter" "cognito_app_client_id" {
  name  = "/cognito/cognito_app_client_id"
  type  = "String"
  value = aws_cognito_user_pool_client.main.id
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/cognito/cognito_app_pool_id"
  type  = "String"
  value = aws_cognito_user_pool.main.id
}



resource "aws_ssm_parameter" "ec2_bastion_host_private_key" {
  name  = "/ec2/bastion/ec2_bastion_host_private_key"
  type  = "String"
  value = tls_private_key.ec2_bastion_host_key_pair.private_key_pem
}

resource "aws_ssm_parameter" "ec2_bastion_host_public_key" {
  name  = "/ec2/bastion/ec2_bastion_host_public_key"
  type  = "String"
  value = tls_private_key.ec2_bastion_host_key_pair.public_key_openssh
}

resource "aws_ssm_parameter" "bastion_public_ip" {
  name  = "/ec2/bastion/ec2_bastion_public_ip"
  type  = "String"
  value = aws_instance.bastion_host.public_ip
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/rds/postgres/endpoint_url"
  type  = "String"
  value = aws_db_instance.main.endpoint
}

resource "aws_ssm_parameter" "db_instance_db_name" {
  name  = "/rds/postgres/endpoint_url"
  type  = "String"
  value = var.db_instance_db_name
}

resource "aws_ssm_parameter" "db_instance_username" {
  name  = "/rds/postgres/endpoint_url"
  type  = "String"
  value = var.db_instance_username
}

resource "aws_ssm_parameter" "db_instance_password" {
  name  = "/rds/postgres/endpoint_url"
  type  = "String"
  value = var.db_instance_password
}
