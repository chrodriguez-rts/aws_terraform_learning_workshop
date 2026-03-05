# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Fetch current AWS region for outputs
data "aws_region" "current" {}

# Primary VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-core-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Public workload subnet
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = {
    Name        = "vpc-subnet-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "vpc-igw-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "vpc-rt-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table association
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security group
resource "aws_security_group" "default_sg" {
  name        = "default-sg-${var.environment}"
  description = "Default security group for VPC"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "default-sg-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# HTTPS ingress
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.default_sg.id
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"

  tags = {
    Name        = "allow-https-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# SSH ingress
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.default_sg.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "tcp"

  tags = {
    Name        = "allow-ssh-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Egress
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name        = "allow-outbound-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}