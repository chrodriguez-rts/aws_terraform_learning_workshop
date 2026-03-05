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

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zones for the VPC subnets"
  type        = list(string)
}