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