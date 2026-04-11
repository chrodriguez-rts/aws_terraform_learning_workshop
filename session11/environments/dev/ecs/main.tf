terraform {
  backend "s3" {
    bucket         = "chris-terraform-state-2026"
    key            = "dev/ecs/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

# Provider configuration — owned by the calling environment
provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "chris-terraform-state-2026"
    key = "dev/vpc/terraform.tfstate"
    region = "us-east-1"
  }

}

module "ecs" {
  source      = "../../../modules/ecs"
  environment = "dev"
  region      = "us-east-1"
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  security_group_id = data.terraform_remote_state.vpc.outputs.security_group_id
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}
