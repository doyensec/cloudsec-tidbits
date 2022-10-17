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
