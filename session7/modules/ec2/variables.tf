variable "region" {
  description = "AWS region where the VPC will be deployed"
  type        = string
}
variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, production)"
  type        = string
}

variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The IDs of the security groups for the VPC"
  type        = list(string)
}

variable "public_key" {
  description = "The SSH public key content for the bastion host"
  type        = string
}

variable "bastion_subnet_id" {
  description = "The ID of the public subnet for the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the bastion security group"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the bastion host (e.g. your_ip/32)"
  type        = string
}
