# Disaster Recovery & Business Continuity Plan

## 1. Objectives & Target Metrics

| Metric | Target SLA | Strategy to Achieve Target |
|:---|:---|:---|
| **RPO (Recovery Point Objective)** | **< 1 Hour** | Automated hourly encrypted PostgreSQL dumps to S3 with bucket versioning. |
| **RTO (Recovery Time Objective)** | **< 15 Minutes** | Terraform IaC automation for cluster provisioning; automated restore scripts. |
| **MTTR (Mean Time to Recover)** | **< 10 Minutes** | Docker Swarm self-healing orchestrator auto-reschedules failed container tasks. |

---

## 2. Failure Scenarios & Recovery Procedures

### Scenario A: Single Worker Node Hardware Crash
- **Impact**: Loss of one compute instance and hosted container replicas.
- **Automated Response**:
  1. Docker Swarm Manager detects missed node heartbeats (heartbeat timeout: 5s).
  2. Swarm scheduler immediately redistributes terminated tasks to surviving worker nodes.
  3. AWS Auto Scaling Group health check fails for the terminated EC2 instance.
  4. ASG launches a replacement EC2 instance; user-data bootstrap script runs Docker, contacts SSM, and rejoins the cluster as a worker.
- **RTO**: Under 30 seconds (zero data loss).

### Scenario B: Database Container Corruption / Unintended Deletion
- **Impact**: Database process down or data file corruption.
- **Recovery Procedure**:
  1. Execute database restore script:
     ```bash
     ./scripts/backup/restore-database.sh s3://enterprise-cloud-prod-backups/database/enterprise_db_LATEST.sql.gz.enc
     ```
  2. The script downloads the encrypted snapshot from S3, verifies the SHA-256 integrity checksum, decrypts via AES-256, and pipes SQL statements into the active PostgreSQL container.
- **RTO**: 5–8 minutes.

### Scenario C: Complete AWS Availability Zone Outage
- **Impact**: Entire datacenter (e.g., `us-east-1a`) becomes unreachable.
- **Automated Response**:
  1. The AWS Application Load Balancer detects unhealthy targets in AZ-1 and immediately routes 100% of ingress traffic to AZ-2 targets.
  2. The Auto Scaling Group scales up worker capacity in AZ-2 to compensate for lost AZ-1 capacity.
  3. NAT Gateway in AZ-2 continues providing uninterrupted outbound internet connectivity.
- **RTO**: 0 seconds (transparent failover).

### Scenario D: Catastrophic Multi-AZ Cloud Region Failure
- **Impact**: Entire AWS primary region is offline.
- **Recovery Procedure**:
  1. Change `aws_region` parameter in `terraform/environments/prod/terraform.tfvars` to secondary region (e.g., `us-west-2`).
  2. Apply Terraform to spin up secondary VPC, ALB, and Swarm cluster:
     ```bash
     terraform apply -var="aws_region=us-west-2" -auto-approve
     ```
  3. Retrieve database backup from cross-region replicated S3 bucket.
  4. Execute `./scripts/backup/restore-database.sh`.
  5. Update Route 53 DNS records to point to the new ALB DNS endpoint.
- **RTO**: 15–20 minutes.

---

## 3. Disaster Recovery Validation Testing

The operational integrity of DR plans is verified through scheduled disaster simulation scripts (`scripts/disaster-recovery/dr-simulation-test.sh`).

Run the test suite:
```bash
./scripts/disaster-recovery/dr-simulation-test.sh
```
The script validates:
1. Active replica counts across all services.
2. Graceful recovery when a random container is terminated (`docker kill`).
3. Endpoint availability during failover.
4. Cryptographic integrity of the latest backup file (`sha256sum -c`).
