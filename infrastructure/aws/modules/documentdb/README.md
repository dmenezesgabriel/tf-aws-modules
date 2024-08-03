# Terraform AWS DocumentDB Module

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  aws_profile              = var.aws_profile
  aws_region_name          = var.aws_region_name
  project_name             = var.project_name
  availability_zones_count = 2
}

resource "aws_security_group" "document_db_sg" {
  name        = "${var.project_name}-document-db-sg"
  description = "Allow traffic to document db"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [
      aws_security_group.ecs_node_sg.id,
      aws_security_group.bastion_host.id
    ]
  }
}

module "documentdb" {
  source = "../../modules/documentdb"

  name                           = "main"
  aws_profile                    = var.aws_profile
  aws_region_name                = var.aws_region_name
  project_name                   = var.project_name
  documentdb_engine              = "docdb"
  documentdb_user                = "documentdb"
  documentdb_password            = "documentdb"
  documentdb_port                = 27017
  documentdb_instance_count      = 1
  documentdb_instance_class      = "db.t3.medium"
  documentdb_skip_final_snapshot = true
  documentdb_disable_tls         = true
  subnet_ids                     = module.vpc.private_subnets_ids[*]
  vpc_security_group_ids         = [aws_security_group.document_db_sg.id]
  save_to_ssm                    = true
}
```
