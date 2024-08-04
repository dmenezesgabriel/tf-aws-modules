
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

resource "aws_dynamodb_table" "main" {
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key
  range_key    = var.dynamodb_range_key

  ttl {
    attribute_name = var.dynamodb_ttl_attribute_name
    enabled        = var.dynamodb_ttl_enabled
  }

  dynamic "attribute" {
    for_each = var.dynamodb_table_attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes

    }
  }


  tags = {
    Name = "${var.project_name}-dynamodb-table-${var.dynamodb_table_name}"
  }
}

