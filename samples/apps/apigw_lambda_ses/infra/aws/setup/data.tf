data "aws_iam_policy_document" "lambda_ses" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    resources = [
      "*",
    ]

    actions = [
      "ses:SendEmail"
    ]
  }
}
