# AWS Terraform Learning Workshop

This repository documents a hands-on, multi-session cloud engineering programme designed to build production-grade AWS infrastructure from first principles. The programme progresses from Terraform fundamentals through containerisation, Kubernetes orchestration, and automated CI/CD pipelines.

## Project Structure

```
terraform-workshop/
├── .github/
│   └── workflows/
│       └── terraform-vpc.yml         ← CI/CD pipeline (Session 7)
├── bootstrap/
│   └── main.tf                        ← S3, DynamoDB, OIDC provider, IAM role
├── modules/
│   ├── vpc/                           ← Sessions 1-3: Multi-AZ networking
│   ├── ec2/                           ← Sessions 5-6: Compute & bastion host
│   ├── ecs/                           ← Session 8: Containers & load balancer
│   └── eks/                           ← Session 9: Kubernetes orchestration
└── environments/
    └── dev/
        ├── vpc/main.tf                ← dev/vpc/terraform.tfstate
        ├── ec2/main.tf                ← dev/ec2/terraform.tfstate
        ├── ecs/main.tf                ← dev/ecs/terraform.tfstate
        └── eks/main.tf                ← dev/eks/terraform.tfstate
```

---

## Sessions Overview

### Session 1: Terraform Fundamentals & AWS Infrastructure as Code
Introduction to Infrastructure as Code, the Terraform core workflow, and AWS networking basics. A complete flat Terraform project was authored from scratch including VPC, subnet, Internet Gateway, route table, security groups, variables, outputs, and environment-specific `.tfvars` files.

**Key concepts:** Declarative IaC, `terraform init/plan/apply`, resource referencing, `aws_vpc_security_group_ingress_rule`, `.tfvars` environment configuration.

---

### Session 2: Terraform Modules
Refactoring flat infrastructure into a reusable module pattern. Established the separation between module implementation (`modules/vpc/`) and calling environments (`environments/dev/`).

**Key concepts:** Module directory structure, provider inheritance, module output interface, `module.vpc.vpc_id` reference syntax, environment files containing provider + module call only.

---

### Session 3: Advanced Networking & Multi-AZ Architecture
Expanding the VPC module to support multiple availability zones with public and private subnet pairs, NAT Gateway, and two separate route tables.

**Key concepts:** Defence in Depth, NAT Gateway placement, `count` meta-argument, splat expression `[*]`, `depends_on` for hidden AWS API dependencies, `list(string)` variables.

---

### Session 4: Remote State & Team-Safe Infrastructure
Migrating from local state to S3-backed remote state with DynamoDB locking. Introduced the bootstrap problem and two-phase solution.

**Key concepts:** S3 backend configuration, DynamoDB atomic locking, state key path isolation, bootstrap pattern, `terraform init -migrate-state`, `terraform_remote_state` data source.

---

### Session 5: EC2 Instances & IAM
Deploying EC2 compute into private subnets using IAM roles and instance profiles. Introduced `terraform_remote_state` in practice — the EC2 module consumes VPC outputs from S3.

**Key concepts:** IAM role + policy + instance profile pattern, `ec2.amazonaws.com` principal, `AmazonSSMManagedInstanceCore`, cross-environment state consumption.

---

### Session 6: Bastion Host Pattern & SSH Key Pairs
Extending the EC2 module with a bastion host for secure SSH access to private infrastructure. Introduced SSH key pairs, security group referencing, and environment-specific sensitive values.

**Key concepts:** Two-hop SSH pattern, `aws_key_pair`, security group ID referencing (stable vs IP instability), `dev.tfvars` for sensitive values not committed to Git.

---

### Session 7: GitHub Actions, OIDC & CI/CD for Terraform
Transforming manual deployments into an automated, reviewed pipeline. Introduced OIDC authentication as the credential-free alternative to stored AWS access keys.

**Key concepts:** Plan-on-PR / apply-on-merge workflow, OIDC token authentication, IAM role trust policy scoped to repository, `terraform apply -auto-approve`, `terraform import` for pre-existing resources, `working-directory` is repo-root-relative in GitHub Actions.

---

### Session 8: Docker, Amazon ECR, ECS with Fargate & ALB
Introducing the container layer — Docker containerisation, ECR for image storage, ECS with Fargate for orchestration, and an Application Load Balancer for internet-facing traffic routing.

**Key concepts:** Dockerfile layer caching, ECR `scan_on_push`, ECS cluster/task definition/service model, Fargate serverless containers, ALB health checks, `target_type = "ip"` required for Fargate, `dev/ecs/terraform.tfstate` state key isolation.

---

### Session 9: Kubernetes Fundamentals & Amazon EKS
Introducing Kubernetes and Amazon EKS — the industry standard for container orchestration at scale. Covered the Kubernetes object model, EKS control plane vs data plane architecture, and the two-IAM-role pattern.

**Key concepts:** Pod, Deployment, Service, Namespace, EKS control plane (AWS-managed) vs data plane (engineer-managed), cluster role (`eks.amazonaws.com`) vs node role (`ec2.amazonaws.com`), managed node groups vs Fargate, `depends_on` required for IAM policy attachment visibility, EKS sequential minor version upgrade constraint.

---

## Infrastructure Components

### Networking (`modules/vpc/`)
- VPC with DNS support and custom CIDR blocks
- Multi-AZ public and private subnet pairs via `count` meta-argument
- Internet Gateway for public subnet internet access
- NAT Gateway with Elastic IP for private subnet outbound access
- Separate public and private route tables
- Default security group with HTTPS (world-reachable) and SSH (restricted to `10.0.0.0/8`)

### Compute (`modules/ec2/`)
- EC2 instance in private subnet with IAM instance profile
- IAM role with `AmazonSSMManagedInstanceCore` for Systems Manager access
- Bastion host in public subnet with SSH key pair authentication
- Bastion security group scoped to specific IP CIDR
- Security group referencing for private instance SSH access

### Containers (`modules/ecs/`)
- Amazon ECR repository with `scan_on_push` vulnerability scanning
- ECS cluster, task definition (Fargate, 256 CPU / 512 MB), and service (desired count: 2)
- ECS task execution IAM role (`ecs-tasks.amazonaws.com`) with `AmazonECSTaskExecutionRolePolicy`
- Internet-facing Application Load Balancer in public subnets
- ALB target group with health checks (`/health`, 2 healthy / 3 unhealthy thresholds)
- `target_type = "ip"` required for Fargate (no instance ID available)
- Containers deployed in private subnets with no public IPs

### Kubernetes (`modules/eks/`)
- EKS cluster (Kubernetes 1.31) deployed in private subnets
- Cluster IAM role (`eks.amazonaws.com`) with `AmazonEKSClusterPolicy`
- Node IAM role (`ec2.amazonaws.com`) with `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`
- Managed node group (`t3.medium`, scaling: min 1 / desired 2 / max 3)
- `depends_on` on both cluster and node group for IAM policy attachment visibility

### State Management (`bootstrap/`)
- S3 bucket (`chris-terraform-state-2026`) with versioning and AES256 encryption
- DynamoDB table (`terraform-state-locks`) with atomic locking
- GitHub OIDC provider registered as trusted identity provider
- GitHub Actions IAM role scoped to `repo:chrodriguez-rts/aws_terraform_learning_workshop:*`

### CI/CD (`.github/workflows/terraform-vpc.yml`)
- Triggers on `pull_request` (plan) and `push to main` (apply)
- OIDC authentication — no stored AWS credentials
- Terraform version pinned at 1.14.5
- Plan output posted as PR comment for code review
- Apply gated to `github.ref == 'refs/heads/main' && github.event_name == 'push'`

---

## State Key Isolation

Each environment layer has its own S3 state file to prevent cross-environment destruction:

| Environment | State Key |
|---|---|
| VPC | `dev/vpc/terraform.tfstate` |
| EC2 | `dev/ec2/terraform.tfstate` |
| ECS | `dev/ecs/terraform.tfstate` |
| EKS | `dev/eks/terraform.tfstate` |

---

## Deployment Order

Infrastructure must be deployed and destroyed in dependency order:

**Deploy:**
```bash
# 1. Bootstrap (one-time only)
cd bootstrap && terraform apply

# 2. VPC (networking foundation — all other layers depend on it)
cd environments/dev/vpc && terraform apply

# 3. EC2, ECS, or EKS (any order, each reads VPC outputs from remote state)
cd environments/dev/ecs && terraform init && terraform apply
cd environments/dev/eks && terraform init && terraform apply
```

**Destroy (reverse order — dependent layers first):**
```bash
# 1. Application layers first
cd environments/dev/eks && terraform destroy
cd environments/dev/ecs && terraform destroy
cd environments/dev/ec2 && terraform destroy -var-file="dev.tfvars"

# 2. VPC last
cd environments/dev/vpc && terraform destroy
```

---

## Prerequisites

- Terraform CLI v1.14.5+
- AWS CLI v2.x configured with appropriate credentials
- GitHub repository with OIDC configured (see `bootstrap/main.tf`)

---

## Key Engineering Principles

- **Module boundary rule:** Resource definitions belong in modules, not environment files. Environment files contain provider block and module call only.
- **No module defaults:** Module variables declare no default values — all inputs must be explicit.
- **Destroy order discipline:** Dependent environments must be destroyed before VPC to avoid state conflicts.
- **Security group attributes:** `aws_vpc_security_group_ingress_rule` uses `ip_protocol` (not `protocol`) and `cidr_ipv4` as a string (not `cidr_blocks` as a list).
- **IAM least privilege:** Every IAM role is scoped to the minimum permissions required for its specific component.
- **Sensitive values:** SSH keys, IP allowlists, and other sensitive values live in `dev.tfvars` — never committed to Git.