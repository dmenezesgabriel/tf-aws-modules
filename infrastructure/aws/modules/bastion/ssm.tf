resource "aws_ssm_parameter" "ec2_bastion_host_private_key" {
  name  = "/${var.project_name}/ec2/bastion/ec2-bastion-host-private-key"
  type  = "String"
  value = tls_private_key.ec2_bastion_host_key_pair.private_key_pem
}

resource "aws_ssm_parameter" "ec2_bastion_host_public_key" {
  name  = "/${var.project_name}/ec2/bastion/ec2-bastion-host-public-key"
  type  = "String"
  value = tls_private_key.ec2_bastion_host_key_pair.public_key_openssh
}

resource "aws_ssm_parameter" "bastion_public_ip" {
  name  = "/${var.project_name}/ec2/bastion/ec2-bastion-public-ip"
  type  = "String"
  value = aws_instance.bastion_host.public_ip
}
