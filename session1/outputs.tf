output "vpc_id" {
  description = "The ID of the primary VPC"
  value       = aws_vpc.main.id
}

output "vpc_subnet_id" {
  description = "The ID of the primary VPC subnet"
  value       = aws_subnet.main_subnet.id
}

output "current_aws_region" {
  description = "The current AWS region"
  value       = data.aws_region.current.region
}