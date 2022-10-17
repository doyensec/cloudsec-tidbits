terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "cloudseclabs_ecs_cluster" {
  name = "labs-ecs-cluster"
}

resource "aws_ecs_task_definition" "lab_dataimport_task" {
  family = "lab-dataimport-task"

  container_definitions    = <<DEFINITION
    [
        {
            "image": "public.ecr.aws/s3v0n4c3/cloudsectidbit-dataimport:latest",
            "name": "cloudsectidbit-dataimport",      
            "essential": true,     
            "environment": [
                    {
                        "name": "BUCKET_NAME",
                        "value": "${aws_s3_bucket.data_internal.bucket}"
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
  #execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecs_role.arn

}

resource "aws_ecs_service" "lab_dataimport_service" {
  name            = "lab-dataimport"
  cluster         = aws_ecs_cluster.cloudseclabs_ecs_cluster.id
  task_definition = aws_ecs_task_definition.lab_dataimport_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.public_vpc_sg.id]
    subnets          = [aws_subnet.public_vpc_subnet.id]
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
    description = "allow egress"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ingress port 443"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ingress port 80"
  }

}

