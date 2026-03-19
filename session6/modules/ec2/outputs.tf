output "instance_id"{
    description = "The ID of the EC2 instance"
    value       = aws_instance.ec2_instance.id
}

output "bastion_public_ip"{
    description = "The public IP your laptop SSH's into"
    value       = aws_instance.bastion_host.public_ip
}

output "bastion_instance_id"{
    description = "The AWS instance ID for reference"
    value       = aws_instance.bastion_host.id
}