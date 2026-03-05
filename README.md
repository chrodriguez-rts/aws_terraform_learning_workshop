# AWS Terraform Learning Workshop

This repository provides a hands-on, multi-session workshop designed to take you from Terraform basics to deploying a professional-grade, modularized AWS infrastructure with remote state management.

## Project Structure

The workshop is organized into four progressive sessions:

* **Session 1: Foundations** – Introduction to AWS provider configuration, basic VPC resources (Subnets, IGW, Route Tables), variables, and outputs.
* **Session 2: Modularization** – Refactoring infrastructure into a reusable VPC module and calling it from environment-specific configurations.
* **Session 3: Advanced Networking** – Expanding the VPC module to support multiple availability zones, public/private subnet pairs, and NAT Gateway integration.
* **Session 4: Remote State & Locking** – Bootstrapping an S3 backend and DynamoDB table to enable secure, concurrent state management.

## Key Features

### Infrastructure Components

* **VPC Core:** Managed VPC with DNS support and custom CIDR blocks.
* **Multi-AZ Subnets:** Support for public and private subnets distributed across specified Availability Zones.
* **Secure Access:** Pre-configured Security Groups with ingress rules for HTTPS (world-reachable) and SSH (restricted to internal networks).
* **NAT & Routing:** Automated routing for public subnets via Internet Gateway and private subnets via NAT Gateway.

### State Management (Session 4)

* **S3 Backend:** Remote storage of Terraform state files with versioning and AES256 encryption.
* **DynamoDB Locking:** Prevents state corruption during concurrent operations by using a dedicated lock table.

## Getting Started

### Prerequisites

* Terraform CLI installed.
* AWS CLI configured with appropriate credentials.

### Deployment Flow

1. **Bootstrap (Optional):** If starting with Session 4, navigate to `session4/bootstrap/` and run `terraform apply` to create the S3 bucket and DynamoDB table.
2. **Initialize:** Navigate to an environment directory (e.g., `session1/` or `session4/environments/dev/`) and run:
```bash
terraform init

```


3. **Plan & Apply:**
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

```



## Outputs

After a successful apply, the following core infrastructure details are surfaced:

* `vpc_id`: The ID of the primary VPC.
* `public_subnet_ids` / `private_subnet_ids`: Lists of created subnet IDs.
* `nat_gateway_id`: The ID of the NAT Gateway used by private subnets.
* `security_group_id`: The ID of the default security group.