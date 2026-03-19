# Configure Terraform to use S3 for remote state storage and DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "chris-terraform-state-2026"
    key            = "dev/ec2/terraform.tfstate"
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

module "ec2" {
  source      = "../../modules/ec2"
  region      = "us-east-1"
  environment = "dev"
  ami = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  private_subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.security_group_id]
}

# Surface the module outputs after apply

output "ec2_instance_id" {
  description = "The ID of the EC2 app server"
  value       = module.ec2.instance_id
}