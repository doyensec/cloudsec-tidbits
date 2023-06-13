################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs             = ["${local.region}a"]
  public_subnets  = ["10.99.0.0/24"]
  private_subnets = ["10.99.3.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = false

  public_route_table_tags  = { Name = "${local.name}-public" }
  public_subnet_tags       = { Name = "${local.name}-public" }
  private_route_table_tags = { Name = "${local.name}-private" }
  private_subnet_tags      = { Name = "${local.name}-private" }

  manage_default_security_group  = true
  default_security_group_name    = "${local.name}-default"
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_dhcp_options      = true
  enable_dns_hostnames     = true
  dhcp_options_domain_name = "ec2.internal"

  //tags = local.tags
}

module "vpc_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-vpc-endpoint"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress_with_self = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Container to VPC endpoint service"
      self        = true
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  //tags = local.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${local.name}"
  retention_in_days = 1

  //tags = local.tags
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
