terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "5.17.0"
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

provider "tls" {
}

data "aws_vpc" "main" {
  tags = { Name = "${var.project_name}-vpc" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Generate new private key
resource "tls_private_key" "ec2_bastion_host_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## AWS SSH Key Pair
resource "aws_key_pair" "ec2_bastion_host_key_pair" {
  key_name   = "${var.project_name}-ec2-bastion-host-key-pair"
  public_key = tls_private_key.ec2_bastion_host_key_pair.public_key_openssh

  tags = {
    Name = "${var.project_name}-bastion-key-pair"
  }
}

# Bastion host
resource "aws_security_group" "bastion_host" {
  name        = "${var.project_name}-bastion-host"
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.main.id

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

  tags = {
    Name = "${var.project_name}-bastion-host-security-group"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.ec2_bastion_host_key_pair.key_name
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  tags = {
    Name = "Bastion_host"
  }
}
