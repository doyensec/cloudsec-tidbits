provider "aws" {
  region = "us-east-1"
}
module "managed-policies" {
  source = "yukihira1992/managed-policies/aws"
}

module "cognito_user_pool" {
  source  = "mineiros-io/cognito-user-pool/aws"
  version = "~> 0.9.0"

  name = "app-userpool"
  default_client_explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH","ALLOW_CUSTOM_AUTH","ALLOW_REFRESH_TOKEN_AUTH","ALLOW_USER_SRP_AUTH"]
  default_client_access_token_validity = 15
  allow_admin_create_user_only = false
  enable_username_case_sensitivity = false

  # password policy
  password_minimum_length    = 6
  password_require_lowercase = false
  password_require_numbers   = false
  password_require_uppercase = false
  password_require_symbols   = false

  clients = [
    {
      name                 = "pill2-tf-app"
      generate_secret      = false
    }
  ]

  schema_attributes = [
    {
      name      = "Role"
      type      = "String"
      developer_only_attribute = false,
      mutable                  = true,
      required                 = false,
      min_length               = 0,
      max_length               = 2048
    }
  ]

  tags = {
    environment = "tidbit-cognito"
  }

}

resource "aws_ecs_cluster" "cloudsecpills_cognito_ecs_cluster" {
  name = "pill-cognito-ecs-cluster"
}

resource "aws_ecs_task_definition" "pill_cognitoapp_task" {
  family = "pill-cognitoapp-task"

  container_definitions    = <<DEFINITION
    [
        {
            "image": "public.ecr.aws/s3v0n4c3/cloudsectidbit-cognitoapp:latest",
            "name": "cloudsectidbit-cognitoapp",      
            "essential": true,     
            "environment": [
                    {
                        "name": "REGION",
                        "value": "us-east-1"
                    },
                    {
                        "name": "CLIENT_ID",
                        "value": "${module.cognito_user_pool.clients["pill2-tf-app"].id}"
                    },
                    {
                        "name" : "USERPOOL_ID",
                        "value" : "${module.cognito_user_pool.user_pool.id}"
                    }
            ],
            "portMappings":[
                {
                    "containerPort" : 80,
                    "hostPort"      : 80
                }
            ],
            "memory"    : 512,
            "cpu"       : 256
        }
    ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  task_role_arn = aws_iam_role.ecs_role.arn

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
  name               = "ecs-role-pill2"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_cognito_policy_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = module.managed-policies.AmazonCognitoPowerUser
}

resource "aws_ecs_service" "pill_cognitoapp_service" {
  name            = "pill-cognitoapp"
  cluster         = aws_ecs_cluster.cloudsecpills_cognito_ecs_cluster.id
  task_definition = aws_ecs_task_definition.pill_cognitoapp_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.public_vpc_sg.id]
    subnets          = [aws_subnet.public_vpc_subnet.id]
  }
}

resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "public_vpc"
  }
}

resource "aws_internet_gateway" "public_vpc_igw" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "public_vpc_igw"
  }
}

resource "aws_route" "public_vpc_route" {
  route_table_id         = aws_vpc.public_vpc.main_route_table_id
  gateway_id             = aws_internet_gateway.public_vpc_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public_vpc_subnet" {
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "public_vpc_subnet"
  }
}

resource "aws_security_group" "public_vpc_sg" {
  vpc_id = aws_vpc.public_vpc.id

  name        = "public_vpc_sg"
  description = "public_vpc_sg"
  tags = {
    Name = "public_vpc_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow egress egress"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ingress egress"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ingress egress"
  }

}