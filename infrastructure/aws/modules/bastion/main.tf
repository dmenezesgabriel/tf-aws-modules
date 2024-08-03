terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}

# Generate new private key
resource "tls_private_key" "ec2_bastion_host_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## AWS SSH Key Pair
resource "aws_key_pair" "ec2_bastion_host_key_pair" {
  key_name   = "${var.project_name}-${var.name}-ec2-bastion-host-key-pair"
  public_key = tls_private_key.ec2_bastion_host_key_pair.public_key_openssh

  tags = {
    Name = "${var.project_name}-${var.name}-bastion-key-pair"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.ec2_bastion_host_key_pair.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  provisioner "remote-exec" {
    inline = var.provisioner_remote_exec
  }

  connection {
    host        = aws_instance.bastion_host.public_ip
    type        = var.ec2_instance_connection_type
    user        = var.ec2_instance_connection_user
    private_key = tls_private_key.ec2_bastion_host_key_pair.private_key_pem
  }

  tags = {
    Name = "${var.project_name}-ec2-${var.name}-instance-bastion-host"
  }
}
