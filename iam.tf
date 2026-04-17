# IAM roles, policies, instance profiles

data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem"
    ]
    resources = [
      aws_dynamodb_table.main.arn
    ]
  }
}

data "aws_iam_policy_document" "ec2_app_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "dynamodb_access" {
  name   = "${local.name_prefix}-dynamodb-access"
  policy = data.aws_iam_policy_document.dynamodb_access.json
  tags = {
    Name = "${local.name_prefix}-dynamodb-access"
  }
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_role" "ec2_app_role" {
  name               = "${local.name_prefix}-ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_app_role.json
  tags = {
    Name = "${local.name_prefix}-ec2-app-role"
  }
}

resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "${local.name_prefix}-app-ec2-profile"
  role = aws_iam_role.ec2_app_role.name
  tags = {
    Name = "${local.name_prefix}-app-ec2-profile"
  }
}