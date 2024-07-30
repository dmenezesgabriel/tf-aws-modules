# --- ECS Task policies ---
data "aws_iam_policy_document" "ecs_access_policy_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBClusterSnapshots"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "docdb:Connect",
      "docdb:DescribeDBInstances",
      "docdb:ListTagsForResource",
      "docdb:ModifyDBClusterParameterGroup",
      "docdb:ModifyDBClusterSnapshotAttribute",
      "docdb:ModifyDBInstance",
      "docdb:DescribeDBClusters",
      "docdb:CreateDBCluster",
      "docdb:DeleteDBCluster",
      "docdb:ListTagsForResource",
      "docdb:CreateDBClusterSnapshot",
      "docdb:ModifyDBCluster",
      "docdb:RebootDBInstance",
      "docdb:RestoreDBClusterToPointInTime"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "cognito-idp:SignUp",
      "cognito-idp:ConfirmSignUp",
      "cognito-idp:ResendConfirmationCode",
      "cognito-idp:AdminGetUser",
      "cognito-idp:InitiateAuth",
      "cognito-idp:ForgotPassword",
      "cognito-idp:ConfirmForgotPassword",
      "cognito-idp:ChangePassword",
      "cognito-idp:GlobalSignOut"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:ExecuteCommand"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}
