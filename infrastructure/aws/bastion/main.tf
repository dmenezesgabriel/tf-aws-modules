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


data "aws_security_group" "bastion_host" {
  name = "${var.project_name}-bastion-host"
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

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.ec2_bastion_host_key_pair.key_name
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [data.aws_security_group.bastion_host.id]

  provisioner "remote-exec" {
    inline = [
      # Add the MongoDB repository
      "echo '[mongodb-org-7.0]' | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo",
      "echo 'name=MongoDB Repository' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
      "echo 'baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/7.0/x86_64/' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
      "echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
      "echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",
      "echo 'gpgkey=https://pgp.mongodb.com/server-7.0.asc' | sudo tee -a /etc/yum.repos.d/mongodb-org-7.0.repo",

      # Install the MongoDB shell package
      "sudo yum install -y mongodb-org",

      # Add the PostgreSQL repository
      "sudo amazon-linux-extras enable postgresql16",

      # Install the PostgreSQL client
      "sudo yum install -y postgresql",

      # Install bind-utils
      "sudo yum install -y bind-utils"
    ]
  }

  connection {
    host        = aws_instance.bastion_host.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.ec2_bastion_host_key_pair.private_key_pem
  }

  tags = {
    Name = "Bastion_host"
  }
}
