# Fetch current AWS region for outputs
data "aws_region" "current" {}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {   
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-app-instance-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
  
}

resource "aws_instance" "ec2_instance" {    
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name        = "ec2-app-instance-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key-${var.environment}"
  public_key = var.public_key

  tags = {
    Name        = "bastion-key-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.environment}"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "bastion-sg-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4       = var.allowed_ssh_cidr

  tags = {
    Name        = "bastion-allow-ssh-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.bastion_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "bastion-host-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

