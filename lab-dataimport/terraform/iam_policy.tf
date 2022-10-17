data "aws_iam_policy_document" "s3_data_bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.data_internal.bucket}"
    ]
  }
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.data_internal.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "dataimport-s3-policy"
  policy = data.aws_iam_policy_document.s3_data_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_s3_data_bucket_policy_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

