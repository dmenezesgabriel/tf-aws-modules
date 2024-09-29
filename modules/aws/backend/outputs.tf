output "backend_state_bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "backend_state_dynamo_lock_table_name" {
  value = aws_dynamodb_table.main.name
}

output "backend_state_kms_key_alias_name" {
  value = aws_kms_alias.main.*.name
}
