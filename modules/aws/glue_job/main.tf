terraform {
  required_version = "~> 1.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


data "aws_iam_policy_document" "role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}



resource "aws_iam_role" "main" {
  name               = "iam_role_${var.glue_job_name}"
  assume_role_policy = data.aws_iam_policy_document.role.json
}

resource "aws_iam_policy" "main" {
  name   = "iam_policy_${var.glue_job_name}"
  policy = var.glue_job_policy_json

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_s3_object" "test_deploy_script_s3" {
  bucket = var.glue_job_bucket
  key    = "glue/scripts/${var.glue_job_name}.py"
  source = var.glue_job_source_file_path
  etag   = filemd5(var.glue_job_source_file_path)
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/glue-job/${var.glue_job_name}"
  retention_in_days = 30
}


resource "aws_glue_job" "test_deploy_script" {
  glue_version      = var.glue_job_version
  max_retries       = var.glue_job_max_retries
  name              = var.glue_job_name
  role_arn          = aws_iam_role.main.arn
  number_of_workers = var.glue_job_number_of_workers
  worker_type       = var.glue_job_worker_type
  timeout           = var.glue_job_worker_timeout
  execution_class   = var.glue_job_worker_execution_class

  command {
    script_location = "s3://${var.glue_job_bucket}/glue/scripts/${var.glue_job_name}.py"
  }

  default_arguments = {
    "--continuous-log-logGroup"    = aws_cloudwatch_log_group.main.name
    "--region"                     = var.region
    "--class"                      = "GlueApp"
    "--enable-job-insights"        = "true"
    "--enable-auto-scaling"        = "false"
    "--enable-glue-datacatalog"    = "true"
    "--job-language"               = "python"
    "--job-bookmark-option"        = "job-bookmark-disable"
    "--customer-driver-env-vars"   = var.glue_job_customer_driver_env_vars
    "--customer-executor-env-vars" = var.glue_job_customer_executor_env_vars
    "--additional-python-modules"  = var.glue_job_aditional_python_modules
  }
}
