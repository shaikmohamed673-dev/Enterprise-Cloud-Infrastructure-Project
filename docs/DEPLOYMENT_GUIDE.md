# Complete Production Deployment Guide

This guide provides end-to-end instructions for provisioning the infrastructure, bootstrapping the Docker Swarm cluster, and deploying the microservice stack.

---

## 1. Prerequisites Checklist

Ensure the following tools and access permissions are configured before initiating deployment:
- [AWS Account](https://aws.amazon.com/) with administrative or power-user IAM permissions.
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and authenticated (`aws configure`).
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (version >= 1.5.0).
- [Docker Engine](https://docs.docker.com/engine/install/) (for local builds or worker node management).
- An SSH Key Pair registered in your AWS region (e.g., `enterprise-cloud-key`).

---

## 2. Infrastructure Provisioning via Terraform

### Step 2.1: Select Environment
Navigate to the production environment directory:
```bash
cd terraform/environments/prod
```

### Step 2.2: Configure Variables
Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` with your target AWS Region and your IP CIDR block for administration:
```hcl
aws_region        = "us-east-1"
project_name      = "enterprise-cloud"
environment       = "prod"
admin_cidr_blocks = ["YOUR_OFFICE_OR_HOME_IP/32"]
```

### Step 2.3: Initialize and Validate
```bash
terraform init
terraform fmt -check
terraform validate
```

### Step 2.4: Execute Deployment Plan
```bash
terraform plan -out=prod.plan
terraform apply prod.plan
```

### Step 2.5: Collect Terraform Outputs
Save the generated infrastructure identifiers:
```bash
terraform output alb_dns_name
terraform output swarm_manager_private_ip
terraform output backup_bucket_id
```

---

## 3. Docker Swarm Cluster Verification

The EC2 instances execute user-data scripts upon launch that automatically install Docker CE and configure the Swarm.

### Step 3.1: Connect to Swarm Manager via AWS SSM
Because the nodes reside in private subnets, connect securely without public IP or open port 22 using AWS Systems Manager Session Manager:
```bash
aws ssm start-session --target <MANAGER_INSTANCE_ID>
```

### Step 3.2: Verify Swarm Cluster Status
Run the following command on the manager node:
```bash
docker node ls
```
Expected output:
```text
ID                            HOSTNAME                                  STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
v89s0... *                    ip-10-0-11-20.ec2.internal                Ready     Active         Leader           26.0.0
k9a1p...                      ip-10-0-11-85.ec2.internal                Ready     Active                          26.0.0
m7b2q...                      ip-10-0-12-140.ec2.internal               Ready     Active                          26.0.0
```

### Step 3.3: Verify Overlay Networks
```bash
docker network ls
```
Confirm `frontend-net`, `backend-net`, and `monitoring-net` are listed with `overlay` scope.

---

## 4. Stack Deployment

### Step 4.1: Deploy Observability Stack
From the manager node inside the repository root:
```bash
cd docker-swarm
docker stack deploy -c monitoring-stack.yml monitoring
```
Verify monitoring services:
```bash
docker stack services monitoring
```

### Step 4.2: Create Cluster Secrets
Create the database password secret if not already created during bootstrap:
```bash
openssl rand -base64 24 | docker secret create db_password -
```

### Step 4.3: Deploy Application Stack
```bash
docker stack deploy -c app-stack.yml enterprise
```
Verify application services:
```bash
docker stack services enterprise
```

Expected output:
```text
ID             NAME                     MODE         REPLICAS   IMAGE                               PORTS
w3t2y8...      enterprise_api           replicated   3/3        enterprise-cloud-api:latest         
o8k1j9...      enterprise_nginx-proxy   replicated   2/2        nginx:1.25-alpine                   *:80->80/tcp
p1m3v7...      enterprise_postgres      replicated   1/1        postgres:16-alpine                  
r9s4x2...      enterprise_redis         replicated   1/1        redis:7.2-alpine                    
v5b6n8...      enterprise_visualizer    replicated   1/1        dockersamples/visualizer:stable     *:8088->8080/tcp
```

---

## 5. Production Smoke Testing & Health Validation

### Step 5.1: Test ALB Endpoint
From any internet-connected machine:
```bash
ALB_URL=$(cd terraform/environments/prod && terraform output -raw alb_dns_name)

# 1. Test root metadata endpoint
curl -s http://${ALB_URL}/ | jq

# 2. Test deep health probe
curl -s http://${ALB_URL}/health | jq

# 3. Test data CRUD operation
curl -s -X POST http://${ALB_URL}/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Production Verification Test", "status": "active"}' | jq
```

### Step 5.2: Access Observability Dashboards
- **Grafana**: `http://<MANAGER_IP_OR_BASTION>:3000` (Default credentials: `admin` / `admin_secure_cloud`)
- **Prometheus**: `http://<MANAGER_IP_OR_BASTION>:9090`
- **Swarm Visualizer**: `http://<MANAGER_IP_OR_BASTION>:8088`

---

## 6. Infrastructure Teardown & Cleanup

When the environment is no longer required:
```bash
# 1. Remove Docker Swarm Stacks
docker stack rm enterprise
docker stack rm monitoring

# 2. Destroy AWS Infrastructure
cd terraform/environments/prod
terraform destroy -auto-approve
```
