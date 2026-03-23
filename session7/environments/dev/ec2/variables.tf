variable "public_key" {
  description = "The public key to use for SSH access to the EC2 instances"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed to SSH into the bastion host"
  type        = string
}