output "vpc_id" {
  description = "The ID of the primary VPC"
  value       = aws_vpc.main.id
}

output "vpc_subnet_id" {
  description = "The ID of the primary VPC subnet"
  value       = aws_subnet.main_subnet.id
}

output "security_group_id" {
  description = "The ID of the default security group"
  value       = aws_security_group.default_sg.id
}