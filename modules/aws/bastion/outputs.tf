output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
