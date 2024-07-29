# Terraform AWS RDS Module

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  aws_profile              = var.aws_profile
  aws_region_name          = var.aws_region_name
  project_name             = var.project_name
  availability_zones_count = 2
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic to RDS"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [
      aws_security_group.ecs_node_sg.id,
      aws_security_group.bastion_host.id
    ]
  }
}

module "rds" {
  source = "../../modules/rds"

  name                             = "main"
  aws_profile                      = var.aws_profile
  aws_region_name                  = var.aws_region_name
  project_name                     = var.project_name
  rds_instance_allocated_storage   = 20
  rds_instance_class               = "db.t3.micro"
  rds_instance_engine              = "postgres"
  rds_instance_engine_version      = "16.3"
  rds_instance_db_name             = "postgres"
  rds_instance_user                = "postgres"
  rds_instance_password            = "postgres"
  rds_instance_port                = "5432"
  rds_instance_publicly_accessible = false
  rds_instance_skip_final_snapshot = true
  vpc_security_group_ids           = [aws_security_group.rds_sg.id]
  subnet_ids                       = module.vpc.private_subnets_ids[*]
  save_to_ssm                      = true
}
```
