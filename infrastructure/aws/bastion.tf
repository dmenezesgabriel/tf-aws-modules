# Bastion host

# Generate new private key
resource "tls_private_key" "ec2_bastion_host_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## AWS SSH Key Pair
resource "aws_key_pair" "ec2_bastion_host_key_pair" {
  key_name   = "${var.project_name}-ec2_bastion_host_key_pair"
  public_key = tls_private_key.ec2_bastion_host_key_pair.public_key_openssh
}

# Bastion host
resource "aws_security_group" "bastion_host" {
  name        = "bastion_host"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.ec2_bastion_host_key_pair.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  tags = {
    Name = "Bastion_host"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
