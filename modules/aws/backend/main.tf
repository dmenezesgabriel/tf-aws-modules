terraform {

  required_version = "~> 1.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name                             = var.bucket_name
  dynamodb_table_name                     = var.dynamodb_table_name
  server_side_encryption_instances_number = var.bucket_server_side_encryption_enabled ? 1 : 0
}

resource "aws_kms_key" "main" {
  count = local.server_side_encryption_instances_number

  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  count = local.server_side_encryption_instances_number

  name          = var.kms_alias_name
  target_key_id = aws_kms_key.main[count.index].key_id
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = local.server_side_encryption_instances_number

  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main[count.index].arn
    }
  }
}

resource "aws_dynamodb_table" "main" {
  name           = local.dynamodb_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
