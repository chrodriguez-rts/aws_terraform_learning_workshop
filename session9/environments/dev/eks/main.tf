terraform {
  backend "s3" {
    bucket         = "chris-terraform-state-2026"
    key            = "dev/eks/terraform.tfstate"
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

module "eks" {
  source = "../../../modules/eks"

  region           = "us-east-1"
  environment      = "dev"
  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}
