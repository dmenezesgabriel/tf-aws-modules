variable "lambda_layer_name" {
  description = "Lambda layer name"
  type        = string
}

variable "lambda_layer_source_directory" {
  description = "Lambda layer source directory"
  type        = string
}

variable "lambda_layer_archive_file_type" {
  description = "Lambda layer archive file type"
  type        = string
  default     = "zip"
}

variable "lambda_layer_zip_file_output_path" {
  description = "Lambda layer zip file path"
  type        = string
}

variable "lambda_layer_bucket_id" {
  description = "Lambda layer bucket id"
  type        = string
}

variable "lambda_layer_version_compatible_runtimes" {
  description = "Lambda layer version compatible runtimes"
  type        = list(string)
}
