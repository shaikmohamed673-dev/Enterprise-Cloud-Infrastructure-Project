# Terraform Infrastructure as Code (IaC)

This directory contains modularized, production-grade Terraform configurations to provision an enterprise-ready AWS cloud infrastructure for Docker Swarm orchestration.

## 🏗️ Architecture Overview

The Terraform IaC provisions:
1. **Multi-AZ VPC**:
   - Public subnets for Application Load Balancers and NAT Gateways.
   - Private subnets for Docker Swarm Manager and Worker compute nodes.
   - Dual NAT Gateways for high availability across availability zones.
2. **Security Groups**:
   - Defense-in-depth security boundary separating public ingress from Swarm inter-node communication.
   - Explicit ingress rules for Docker Swarm Raft consensus (2377/TCP), node discovery (7946/TCP+UDP), and overlay network encapsulation (4789/UDP).
3. **Application Load Balancer (ALB)**:
   - High-throughput public load balancer with health checking (`/health`) and dynamic target groups.
4. **Compute & Auto Scaling**:
   - Primary Swarm Manager EC2 instance with automated bootstrap script.
   - Swarm Worker Auto Scaling Group (ASG) governed by dynamic Target Tracking (70% CPU threshold).
5. **IAM Least-Privilege Execution Role**:
   - AWS Systems Manager (SSM) agent integration eliminating the need for public SSH ports.
   - S3 backup policy strictly scoped to disaster recovery buckets.
6. **S3 Disaster Recovery Storage**:
   - Server-Side Encryption (AES-256), versioning, and automated Glacier transition lifecycle rules.

---

## 📁 Directory Structure

```text
terraform/
├── environments/
│   ├── prod/                      # Production environment entrypoint
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── staging/                   # Staging environment entrypoint (cost-optimized)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
├── modules/
│   ├── alb/                       # Application Load Balancer & Target Groups
│   ├── compute_swarm/             # EC2 Manager, Worker Launch Template & ASG
│   │   └── scripts/
│   │       ├── manager_bootstrap.sh
│   │       └── worker_bootstrap.sh
│   ├── iam/                       # IAM roles, policies, and instance profiles
│   ├── s3_backups/                # S3 backup bucket with lifecycle and encryption
│   ├── security_groups/           # Layered firewall rules
│   └── vpc/                       # Multi-AZ networking, subnets & routing
├── versions.tf                    # Provider constraints (AWS >= 5.0)
└── README.md
```

---

## 🚀 Deployment Instructions

### Prerequisites
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials (`aws configure`).
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0).

### 1. Configure Variables
Navigate to your desired environment (e.g., `environments/prod`):
```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
```
Adjust parameters such as `aws_region`, `instance_type`, and `admin_cidr_blocks`.

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Validate & Format
```bash
terraform fmt -check
terraform validate
```

### 4. Review Speculative Execution Plan
```bash
terraform plan -out=tfplan
```

### 5. Apply Infrastructure
```bash
terraform apply tfplan
```

### 6. Retrieve Outputs
Once applied, Terraform outputs the public DNS of the Application Load Balancer and internal IPs:
```bash
terraform output alb_dns_name
terraform output swarm_manager_private_ip
```

### 7. Teardown / Destruction (Optional)
To safely tear down all provisioned resources:
```bash
terraform destroy -auto-approve
```
