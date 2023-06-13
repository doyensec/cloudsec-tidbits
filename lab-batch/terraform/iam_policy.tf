data "aws_iam_policy_document" "s3_data_bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "*"
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
      "*"
    ]
  }
   statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "batch:DescribeJobQueues",
      "batch:SubmitJob",
      "batch:CancelJob",
      "batch:TerminateJob",
      "batch:DescribeJobs",
      "batch:ListJobs",
      "batch:DescribeComputeEnvironments",
      "batch:RegisterJobDefinition",
      "batch:DescribeJobDefinitions",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_partition" "current" {}


resource "aws_iam_policy" "s3_policy" {
  name   = "dataimport-s3-policy"
  policy = data.aws_iam_policy_document.s3_data_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_s3_data_bucket_policy_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_global.json

  inline_policy {
    name = "inline-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:GetLogEvents"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

################################################################################
# Compute Environment - Instance Role
################################################################################

resource "aws_iam_instance_profile" "instance" {
  count = var.create && var.create_instance_iam_role ? 1 : 0

  name        = var.instance_iam_role_use_name_prefix ? null : var.instance_iam_role_name
  name_prefix = "iam-instance-profile-"
  path        = var.instance_iam_role_path
  role        = aws_iam_role.instance.name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.instance_iam_role_tags)
}

################################################################################
# Compute Environment - Service Role
################################################################################

data "aws_iam_policy_document" "assume_role_policy_global" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.${data.aws_partition.current.dns_suffix}", "batch.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

data "aws_iam_policy_document" "service" {
  count = var.create && var.create_service_iam_role ? 1 : 0

  statement {
    sid     = "ECSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.${data.aws_partition.current.dns_suffix}", "ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

data "aws_iam_policy_document" "instance" {
  count = var.create && var.create_instance_iam_role ? 1 : 0

  statement {
    sid     = "ECSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

//iam role aws_iam_role service

resource "aws_iam_role" "service" {
  //count = var.create && var.create_service_iam_role ? 1 : 0

  name_prefix = "iam-role-service-"
  path        = "/batch/"
  description = "IAM service role for AWS Batch"

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy_global.json
  permissions_boundary  = var.service_iam_role_permissions_boundary
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }

}

//iam role aws_iam_role instance

resource "aws_iam_role" "instance" {
  //count = var.create && var.create_instance_iam_role ? 1 : 0

  name_prefix = "iam-instance-role-"
  path        = "/batch/"
  description = "IAM instance role/profile for AWS Batch ECS instance(s)"

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy_global.json
  permissions_boundary  = var.instance_iam_role_permissions_boundary
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.instance_iam_role_tags)
}


resource "aws_iam_role_policy_attachment" "service" {
  for_each = var.create && var.create_service_iam_role ? toset(compact(distinct(concat([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBatchServiceRole"
  ], var.service_iam_role_additional_policies)))) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.service.name
}

resource "aws_iam_role_policy_attachment" "instance" {

  for_each = var.create && var.create_instance_iam_role ? toset(compact(distinct(concat([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ], [ "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] )))) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.instance.name
}