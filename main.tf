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