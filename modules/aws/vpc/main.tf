terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
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
  azs_count = var.availability_zones_count
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
