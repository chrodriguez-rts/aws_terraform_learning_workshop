variable "region" {
  description = "AWS region where the VPC will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, production)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.10.0.0/16)"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the primary workload subnet (must be a subset of vpc_cidr)"
  type        = string
}