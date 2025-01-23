terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_vpc" "project_vpc" {
  cidr_block       = var.vpc_cidr_block
  
  tags = {
    Name = "proj-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  count = 3
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 3, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 3
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 3, count.index+3)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "proj-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "proj_public_rtb"
  }
}

resource "aws_route_table_association" "public_rtb_association" {
  count = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_security_group" "project_sg" {
  name        = "project-sg"
  vpc_id      = aws_vpc.project_vpc.id

  tags = {
    Name = "proj_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  security_group_id = aws_security_group.project_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.project_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
}

resource "aws_instance" "nginx" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  security_groups = [aws_security_group.project_sg.id]

  tags = {
    Name = "proj-nginx-instance"
  }
}