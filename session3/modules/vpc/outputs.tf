output "vpc_id" {
  description = "The ID of the primary VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "The ID of the default security group"
  value       = aws_security_group.default_sg.id
}

output "current_aws_region" {
  description = "The AWS region where the VPC is deployed"
  value       = data.aws_region.current.region
  
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private_rt.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
  
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
