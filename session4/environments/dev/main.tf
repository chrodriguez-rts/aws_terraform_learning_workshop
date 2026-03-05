# Configure Terraform to use S3 for remote state storage and DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "chris-terraform-state-2026"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

# Provider configuration — owned by the calling environment
provider "aws" {
  region = "us-east-1"
}

# Call the VPC module with dev-specific values
module "vpc" {
  source      = "../../modules/vpc"
  region      = "us-east-1"
  environment = "dev"
  vpc_cidr    = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.3.0/24"]
  private_subnet_cidrs = ["10.10.2.0/24", "10.10.4.0/24"]
}

# Surface the module outputs after apply
output "vpc_id" {
  description = "VPC ID from the vpc module"
  value       = module.vpc.vpc_id
}

output "security_group_id" {
  description = "Security Group ID from the vpc module"
  value       = module.vpc.security_group_id
}

output "current_aws_region" {
  description = "AWS region from the vpc module"
  value       = module.vpc.current_aws_region
}

output "nat_gateway_id" {
  description = "NAT Gateway ID from the vpc module"
  value       = module.vpc.nat_gateway_id
}

output "public_route_table_id" {
  description = "Public Route Table ID from the vpc module"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "Private Route Table ID from the vpc module"
  value       = module.vpc.private_route_table_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs from the vpc module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet IDs from the vpc module"
  value       = module.vpc.private_subnet_ids
}