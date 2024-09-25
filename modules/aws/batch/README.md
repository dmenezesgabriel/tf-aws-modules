```hcl
module "vpc" {
  source = "../../modules/vpc"

  aws_profile              = var.aws_profile
  aws_region_name          = var.aws_region_name
  project_name             = var.project_name
  availability_zones_count = 2
}

resource "aws_security_group" "ecs_node_sg" {
  name   = "${var.project_name}-ecs-node-sg"
  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "batch" {
  source = "../../modules/batch"

  name                        = "command-alembic-migration"
  aws_profile                 = var.aws_profile
  aws_region_name             = var.aws_region_name
  project_name                = var.project_name
  image_tag                   = "20240730141203"
  ecs_repository_name         = "ecs-todo-command"
  command                     = ["alembic", "-c", "migrations/alembic/alembic.ini", "upgrade", "head"]
  batch_policy                = data.aws_iam_policy_document.ecs_access_policy_doc.json
  compute_resource_subnet_ids = module.vpc.private_subnets_ids[*]
  security_group_ids          = [aws_security_group.ecs_node_sg.id]
  environment = [
    { name = "AWS_REGION_NAME", value = var.aws_region_name },
    { name = "ENVIRONMENT", value = "staging" }
  ]
}

```
