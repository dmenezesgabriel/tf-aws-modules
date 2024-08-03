# Terraform AWS EC2 Bastion Host Module

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  aws_profile              = var.aws_profile
  aws_region_name          = var.aws_region_name
  project_name             = var.project_name
  availability_zones_count = 2
}

resource "aws_security_group" "bastion_host" {
  name        = "${var.project_name}-bastion-host"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

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

  ingress {
    description = "SSH from VPC"
    from_port   = 27017
    to_port     = 27017
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

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

module "bastion" {
  source = "../../modules/bastion"

  name                         = "main"
  aws_profile                  = var.aws_profile
  aws_region_name              = var.aws_region_name
  project_name                 = var.project_name
  ec2_instance_type            = "t2.micro"
  ec2_instance_ami             = data.aws_ssm_parameter.ecs_node_ami.value
  subnet_id                    = module.vpc.public_subnets_ids[0]
  vpc_security_group_ids       = [aws_security_group.bastion_host.id]
  ec2_instance_connection_type = "ssh"
  ec2_instance_connection_user = "ec2-user"
  provisioner_remote_exec = [
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
  save_to_ssm = true
}
```
