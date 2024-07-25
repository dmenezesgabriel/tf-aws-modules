terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "5.17.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_name
}

# --- VPC ---

data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names
}

resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-${local.azs_names[count.index]}"
    Type = "public"

  }
}

resource "aws_subnet" "private" {
  count             = local.azs_count
  vpc_id            = aws_vpc.main.id
  availability_zone = local.azs_names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 100 + count.index)
  tags = {
    Name = "${var.project_name}-private-${local.azs_names[count.index]}"
    Type = "private"
  }
}

# --- Nat Gateway ---
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.project_name}-nat"
  }
}


resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.main]
  tags       = { Name = "${var.project_name}-eip" }
}
# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# --- Public Route Table ---
# Load Balancer requires at least two subnets created in different
# Availability Zones (AZ).

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private Route Table ---
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-rt-private"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

resource "aws_route_table_association" "private" {
  count          = local.azs_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# --- Security Groups ---
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.main.id

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


resource "aws_security_group" "document_db_sg" {
  name        = "${var.project_name}-document-db-sg"
  description = "Allow traffic to document db"
  vpc_id      = aws_vpc.main.id

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

# --- ECS Node SG ---
# Security Group for ECS Node which allow outgoing traffic (its required to
# pull image to start service later)

resource "aws_security_group" "ecs_node_sg" {
  name   = "${var.project_name}-ecs-node-sg"
  vpc_id = aws_vpc.main.id

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


resource "aws_security_group" "ecs_task" {
  name        = "${var.project_name}-ecs-task-sg"
  description = "Allow all traffic within the VPC"
  vpc_id      = aws_vpc.main.id

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

resource "aws_security_group" "bastion_host" {
  name        = "${var.project_name}-bastion-host"
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

# --- VPC Endpoints ---
data "aws_iam_policy_document" "s3_ecr_access" {
  version = "2012-10-17"
  statement {
    sid     = "s3access"
    effect  = "Allow"
    actions = ["*"]

    principals {
      type        = "*"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region_name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  policy            = data.aws_iam_policy_document.s3_ecr_access.json

  tags = {
    Name = "${var.project_name}/s3-endpoint"
  }
}


resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region_name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_task.id]
  tags = {
    Name = "${var.project_name}/ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region_name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.ecs_task.id]

  tags = {
    Name = "${var.project_name}/ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.aws_region_name}.logs"
  subnet_ids        = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}/cloudwatch-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region_name}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecs_task.id]
  subnet_ids          = aws_subnet.private[*].id


}
resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region_name}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecs_task.id]
  subnet_ids          = aws_subnet.private[*].id
}
