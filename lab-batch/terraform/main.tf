terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  region = "us-east-1"
  name   = "batch-tidbit"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_template" "custom_launch_template" {
  user_data = base64encode(data.template_file.data_userdata_script.rendered)
}

data "template_file" "data_userdata_script" {
  template = file("${path.module}/user_data.tpl")
}

################################################################################
# Compute Environment(s)
################################################################################

resource "aws_batch_compute_environment" "ce_managed" {

  service_role = aws_iam_role.service.arn
  type         = "MANAGED"

  compute_resources {
      type           = "EC2"
      min_vcpus      = 1
      max_vcpus      = 4
      desired_vcpus  = 2
      instance_type = ["m5.large", "r5.large"]

      instance_role       = try(aws_iam_instance_profile.instance[0].arn, null)

      security_group_ids = [module.vpc_endpoint_security_group.security_group_id]
      subnets            = module.vpc.private_subnets

      launch_template {
        launch_template_id = aws_launch_template.custom_launch_template.id
      }

      tags = {
          Name = local.name
          Type = "Ec2"
      }
  }

  # Prevent a race condition during environment deletion, otherwise the policy may be destroyed
  # too soon and the compute environment will then get stuck in the `DELETING` state
  depends_on = [aws_iam_role_policy_attachment.service]

}

resource "aws_batch_compute_environment" "ce_fargate" {

  service_role = aws_iam_role.service.arn
  type         = "MANAGED"

  compute_resources {
    max_vcpus = 4

    security_group_ids = [module.vpc_endpoint_security_group.security_group_id]
    subnets = module.vpc.private_subnets

    type = "FARGATE"
  }

  # Prevent a race condition during environment deletion, otherwise the policy may be destroyed
  # too soon and the compute environment will then get stuck in the `DELETING` state
  depends_on = [aws_iam_role_policy_attachment.service]

}

################################################################################
# Job Queue(s)
################################################################################

resource "aws_batch_job_queue" "jq_managed" {

  name     = "LowPriorityEc2"
  state    = "ENABLED"
  priority = 1

  scheduling_policy_arn = aws_batch_scheduling_policy.scheduling_policy.arn
  compute_environments  = [aws_batch_compute_environment.ce_managed.arn]
}

resource "aws_batch_job_queue" "jq_fargate" {

  name     = "LowPriority-Fargate"
  state    = "ENABLED"
  priority = 1

  scheduling_policy_arn = aws_batch_scheduling_policy.scheduling_policy.arn
  compute_environments  = [aws_batch_compute_environment.ce_fargate.arn]
}

################################################################################
# Scheduling Policy
################################################################################

resource "aws_batch_scheduling_policy" "scheduling_policy" {
  name = "scheduling-policy"
}

################################################################################
# Job Definitions
################################################################################

resource "aws_batch_job_definition" "job_def_ec2" {

  name           = "job-def-ec2"
  type           = "container"

  container_properties = jsonencode({
        command = ["sleep", "4h"]
        image   = "curlimages/curl"
        resourceRequirements = [
          { type = "VCPU", value = "1" },
          { type = "MEMORY", value = "1024" }
        ]
        privileged = false
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.this.id
            awslogs-region        = local.region
            awslogs-stream-prefix = local.name
          }
        }
        executionRoleArn = aws_iam_role.ecs_role.arn 
        jobRoleArn = aws_iam_role.ecs_role.arn 
  })
  
  timeout {
    attempt_duration_seconds = 600 //10 mins
  }

}

resource "aws_batch_job_definition" "job_def_fargate" {
  name           = "job-def-fargate"
  type           = "container"

  platform_capabilities = [
    "FARGATE",
  ]

  container_properties = jsonencode({
        command = ["sleep", "5h"]
        image   = "curlimages/curl"
        
        fargatePlatformConfiguration = {
          platformVersion = "LATEST"
        }

        resourceRequirements = [
          { type = "VCPU", value = "1" },
          { type = "MEMORY", value = "2048" }
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.this.id
            awslogs-region        = local.region
            awslogs-stream-prefix = local.name
          }
        }
        executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
        jobRoleArn = aws_iam_role.ecs_role.arn 
  })

  timeout {
    attempt_duration_seconds = 600 //10 mins
  }

}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "tf_test_batch_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
