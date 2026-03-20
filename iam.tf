data "aws_iam_policy_document" "pingfederate_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pingfederate" {
  name_prefix        = "${var.project_name}-pingfederate-"
  assume_role_policy = data.aws_iam_policy_document.pingfederate_assume_role.json

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })
}

resource "aws_iam_instance_profile" "pingfederate" {
  name_prefix = "${var.project_name}-pingfederate-"
  role        = aws_iam_role.pingfederate.name

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })
}

# S3 (artifact download)

data "aws_iam_policy_document" "pingfederate_s3" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "pingfederate_s3" {
  name_prefix = "${var.project_name}-s3-"
  role        = aws_iam_role.pingfederate.id
  policy      = data.aws_iam_policy_document.pingfederate_s3.json
}
