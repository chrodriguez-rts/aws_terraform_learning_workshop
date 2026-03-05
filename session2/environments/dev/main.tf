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
  subnet_cidr = "10.10.1.0/24"
}

# Surface the module outputs after apply
output "vpc_id" {
  description = "VPC ID from the vpc module"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "Subnet ID from the vpc module"
  value       = module.vpc.vpc_subnet_id
}

output "security_group_id" {
  description = "Security Group ID from the vpc module"
  value       = module.vpc.security_group_id
}