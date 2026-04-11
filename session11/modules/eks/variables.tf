variable "region" {
  description = "AWS region where the VPC will be deployed"
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment for which to create resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EKS cluster will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnet IDs for the EKS cluster"
}