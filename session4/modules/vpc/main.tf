
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
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-subnet-${var.availability_zones[count.index]}-${var.environment}"
  }
}

 # Private workload subnet
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${var.availability_zones[count.index]}-${var.environment}"
  }
}

# Internet Gateway — the VPC's front door to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "vpc-internet-gateway-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table — directs internet-bound traffic to the IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "vpc-public-route-table-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table — directs traffic to NAT Gateway for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "vpc-private-route-table-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "public_rta" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
  # Note: aws_route_table_association does not support tags
}

# Associate the subnet with the route table
resource "aws_route_table_association" "private_rta" {
 count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
  # Note: aws_route_table_association does not support tags
}

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

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.gw] 

  tags = {
    Name        = "nat-gateway-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "nat-eip-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.default_sg.id
  from_port        = 443
  to_port          = 443
  cidr_ipv4        = "0.0.0.0/0" # Allow HTTPS from anywhere
  ip_protocol = "tcp"

  tags = {
    Name        = "allow-https-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.default_sg.id
  from_port        = 22
  to_port          = 22
  cidr_ipv4        = "10.0.0.0/8"  # Restrict SSH access to internal network
  ip_protocol = "tcp"

  tags = {
    Name        = "allow-ssh-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4        = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name        = "allow-all-outbound-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}