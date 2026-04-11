variable "region" {
  description = "AWS region where the VPC will be deployed"
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment to deploy to (e.g., dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs for the ECS cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "A list of public subnet IDs for the ECS cluster"
}

variable "security_group_id" {
  type        = string
  description = "The security group ID for the ECS cluster"
}
