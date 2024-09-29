data "archive_file" "main" {
  output_path = var.lambda_layer_zip_file_output_path
  source_dir  = var.lambda_layer_source_directory
  type        = var.lambda_layer_archive_file_type
}

resource "aws_s3_object" "main" {
  bucket = var.lambda_layer_bucket_id
  key    = "layers/${var.lambda_layer_name}.zip"
  source = data.archive_file.main.output_path
}

resource "aws_lambda_layer_version" "main" {
  s3_bucket           = var.lambda_layer_bucket_id
  s3_key              = aws_s3_object.main.key
  layer_name          = var.lambda_layer_name
  compatible_runtimes = var.lambda_layer_version_compatible_runtimes
  source_code_hash    = data.archive_file.main.output_base64sha256
  depends_on          = [aws_s3_object.main]
}
