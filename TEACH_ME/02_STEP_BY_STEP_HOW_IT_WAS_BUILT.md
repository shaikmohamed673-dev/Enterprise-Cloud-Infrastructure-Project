# Teach Me: Deep Dive — How Every Single File Was Built

This document breaks down the entire codebase file by file, explaining what each file does, why it exists, and how the parts connect together.

---

## 1. Directory Structure Map

```text
├── terraform/                --> Provisions AWS Cloud Infrastructure
├── docker-swarm/             --> Orchestrates Docker Containers
├── app/                      --> The Application (Python FastAPI + Nginx)
├── monitoring/               --> Prometheus & Grafana Configuration
├── security/                 --> OS & Docker Hardening Scripts
├── scripts/                  --> Backups & Disaster Recovery
├── .github/workflows/        --> Automated CI/CD Pipelines
└── docs/                     --> Architecture Diagrams & Reports
```

---

## 2. Terraform (Infrastructure as Code) Breakdown

### A. Why Modules? (`terraform/modules/`)
Instead of dumping 1,000 lines into one giant file, we separated the cloud infrastructure into reusable building blocks:
1. `modules/vpc/`:
   - `aws_vpc`: Creates the virtual network (`10.0.0.0/16`).
   - `aws_subnet.public`: Subnets with direct internet access via Internet Gateway (`aws_internet_gateway.igw`).
   - `aws_subnet.private`: Isolated subnets with NO direct internet.
   - `aws_nat_gateway`: Translates outbound requests from private subnets so servers can download packages and pull Docker images without exposing themselves to incoming attacks.
2. `modules/security_groups/`:
   - Acts as virtual firewalls at the instance level.
   - `alb-sg`: Allows incoming ports 80 (HTTP) and 443 (HTTPS) from anywhere (`0.0.0.0/0`).
   - `swarm-manager-sg` & `swarm-worker-sg`: Only accepts HTTP on port 80 if it comes from the ALB.
   - Swarm ports:
     - `2377/tcp`: Swarm cluster management (Raft consensus).
     - `7946/tcp` and `7946/udp`: Gossip protocol for node discovery.
     - `4789/udp`: VXLAN overlay network data plane.
3. `modules/compute_swarm/`:
   - Queries Ubuntu 22.04 LTS AMI (`data "aws_ami" "ubuntu"`).
   - Provisions Swarm Manager EC2 instance with `manager_bootstrap.sh`.
   - Creates `aws_launch_template` and `aws_autoscaling_group` for worker nodes.
   - Configures `aws_autoscaling_policy` with **Target Tracking at 70% CPU**. If the cluster experiences high traffic, AWS automatically spins up new worker EC2 instances!
4. `modules/s3_backups/`:
   - Creates an S3 bucket with strict security:
     - `aws_s3_bucket_public_access_block`: Denies ALL public access.
     - `aws_s3_bucket_versioning`: Protects against accidental deletion or ransomware overwrites.
     - `aws_s3_bucket_server_side_encryption_configuration`: Encrypts all stored data with AES-256.
     - `aws_s3_bucket_lifecycle_configuration`: Moves backups older than 30 days to Glacier (cheap archive storage) and deletes after 365 days.
5. `modules/iam/`:
   - Creates an IAM Role for EC2 instances.
   - Attaches `AmazonSSMManagedInstanceCore` so engineers can log into servers via AWS Systems Manager without opening SSH port 22 to the world!

### B. Environment Separation (`terraform/environments/`)
- `prod/`: High availability setup with 2 NAT Gateways and `t3.medium` instances.
- `staging/`: Identical architecture, but uses a single NAT Gateway (`single_nat_gateway = true`) and `t3.small` instances to save money while verifying changes.

---

## 3. The Application & Microservice (`app/`)

### A. The FastAPI Service (`app/src/app.py`)
This is not a dummy script; it is a full production microservice:
- Uses **FastAPI**, an asynchronous, high-performance Python web framework.
- Built-in Prometheus instrumentation:
  - `enterprise_http_requests_total`: Counts every request by HTTP method, route, and status code.
  - `enterprise_http_request_duration_seconds`: Histogram measuring exact latency buckets.
  - `enterprise_system_memory_usage_bytes` & `enterprise_system_cpu_percent`: Tracks live CPU and RAM consumption.
- Probes:
  - `GET /health`: Deep check returning memory, CPU, and database status.
  - `GET /health/liveness`: Checks if the process is running.
  - `GET /health/readiness`: Checks if the application is ready to accept traffic.
  - `GET /metrics`: Standard Prometheus scraping endpoint.
  - `POST /api/v1/simulate-load`: Allows you to trigger an artificial CPU spike during an interview demo to show autoscaling and Prometheus alerts!

### B. The Production Dockerfile (`app/Dockerfile`)
Built using enterprise best practices:
1. **Multi-Stage Build**:
   - Stage 1 (`builder`): Installs build tools and python wheels into a temporary image.
   - Stage 2 (`runtime`): Copies only the compiled wheels into a clean, minimal `python:3.11-slim` image. Eliminates compilers, reducing image size from 1 GB to ~130 MB!
2. **Non-Root User**:
   - Creates `appuser` with UID `10001`. The container runs as an unprivileged user, meaning even if a hacker exploits an application vulnerability, they cannot gain root access to the host machine.
3. **Built-in Healthcheck**:
   - Queries `http://localhost:8000/health/liveness` every 30 seconds.

### C. Nginx Reverse Proxy (`app/nginx/nginx.conf`)
- Acts as the frontline gatekeeper.
- Configures **Rate Limiting** (`limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s`): Prevents DDoS attacks and brute-force flooding.
- Injects HTTP security headers (`X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Content-Security-Policy`).
- Gzip compresses all text and JSON responses.

---

## 4. Docker Swarm Orchestration (`docker-swarm/`)

### A. Application Stack (`docker-swarm/app-stack.yml`)
Deploys 5 interconnected microservices:
1. `nginx-proxy`: 2 replicas across worker nodes, listening on port 80.
2. `api`: 3 replicas of our FastAPI microservice.
   - Connected to both `frontend-net` (to talk to Nginx) and `backend-net` (to talk to DB).
   - Configured with rolling update strategy:
     ```yaml
     update_config:
       parallelism: 1
       delay: 15s
       failure_action: rollback
       order: start-first
     ```
     **Why `start-first`?** It spins up the new container *first*, verifies it passes health checks, and only then tears down the old container. Zero seconds of downtime!
3. `redis`: In-memory cache for session data and performance acceleration.
4. `postgres`: Relational database with persistent volume mounted to `/var/lib/postgresql/data`.
5. `visualizer`: Web interface running on manager node (port 8088) providing a graphical map of which containers run on which nodes.

### B. Monitoring Stack (`docker-swarm/monitoring-stack.yml`)
Deploys the complete observability suite:
1. `prometheus`: Scrapes metrics every 15 seconds.
2. `grafana`: Web dashboard running on port 3000.
3. `cadvisor`: Runs in `mode: global` (1 instance on every single Swarm node) to monitor Docker container CPU and memory usage.
4. `node-exporter`: Runs in `mode: global` to capture host OS metrics (CPU, RAM, disk, network).
5. `loki` & `promtail`: Centralized logging engine. Promtail streams container logs directly into Loki.

---

## 5. Security & Disaster Recovery Scripts (`security/` & `scripts/`)

1. `security/harden-node.sh`:
   - Tunes Linux kernel via `sysctl` to drop spoofed IP packets, disable ICMP redirects, and enable TCP SYN Cookies against SYN flood attacks.
   - Configures UFW firewall rules, allowing only necessary Swarm ports.
2. `scripts/backup/backup-database.sh`:
   - Dumps the PostgreSQL database (`pg_dump`).
   - Compresses it with `gzip`.
   - **Encrypts it with OpenSSL AES-256-CBC**. Even if an unauthorized person intercepts the backup, they cannot read your customer data without the decryption key.
   - Generates a SHA-256 checksum and uploads both to AWS S3.
   - Automatically deletes local backups older than 7 days.
3. `scripts/backup/restore-database.sh`:
   - Downloads the encrypted backup from S3, verifies the SHA-256 checksum, decrypts it, and restores it into the database with transaction integrity.
4. `scripts/disaster-recovery/dr-simulation-test.sh`:
   - Kills a running API container and times how many seconds Docker Swarm takes to automatically self-heal and replace it!

---

## 6. Continuous Integration & Delivery (`.github/workflows/`)

1. `terraform-ci.yml`:
   - Runs `terraform fmt -check` (ensures clean code style).
   - Runs `terraform validate` (catches syntax errors).
   - Runs **Trivy** to scan Terraform code for security misconfigurations.
2. `app-ci-cd.yml`:
   - Runs unit tests with `pytest`.
   - Runs vulnerability scanning on the Docker container image.
   - Builds and publishes the image to GitHub Container Registry (`ghcr.io`).
   - Executes zero-downtime rolling update on Docker Swarm.
