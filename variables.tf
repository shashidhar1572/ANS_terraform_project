variable "region" {
  description = "aws region to deploy the resources"
  default = "us-east-1"
}

variable "access_key" {
  description = "your aws access key"
  sensitive = true
  type = string
}

variable "secret_key" {
  description = "your aws secret key"
  sensitive = true
  type = string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "ami_id" {
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  default = "t2.micro"
}