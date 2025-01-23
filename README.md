This Terraform project provisions:
- A VPC with public and private subnets across 3 availability zones.
- An EC2 instance in the public subnet with HTTP (port 80) access.
- Security groups to allow HTTP traffic and unrestricted egress.

Pre-Requisites
1. Install Terraform on your system.
2. Configure AWS credentials using a `terraform.tfvars` file or environment variables.
