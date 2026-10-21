# Enterprise Cloud Infrastructure & DevOps Architecture Specification

## 1. Executive Architectural Overview

This document specifies the technical design, networking topologies, security perimeters, and orchestration components for the **Enterprise Cloud Infrastructure & DevOps Automation** platform.

The infrastructure is engineered for:
- **High Availability (HA)**: Deployed across multiple Availability Zones (`us-east-1a`, `us-east-1b`) in AWS.
- **Resilience & Self-Healing**: Powered by Docker Swarm cluster orchestration with automated health checking and rolling rollbacks.
- **Defense in Depth**: Zero direct internet access to compute nodes; all compute resides in private subnets behind an Application Load Balancer (ALB) and managed NAT Gateways.
- **Full-Stack Observability**: End-to-end metrics scraping via Prometheus, centralized log streaming with Loki/Promtail, and unified visualization via Grafana.

---

## 2. Visual Architecture Diagram

![AWS Enterprise Cloud Architecture](architecture/aws_cloud_architecture.svg)

---

## 3. Network Topology & VPC Segmentation

The AWS VPC is partitioned into isolated layers to adhere to the principle of least privilege:

| Subnet Type | CIDR Block | Availability Zone | Attached Gateways | Hosted Resources |
|:---|:---|:---|:---|:---|
| **Public Subnet 1** | `10.0.1.0/24` | `us-east-1a` | Internet Gateway (IGW) | Application Load Balancer (ALB), NAT Gateway 1 |
| **Public Subnet 2** | `10.0.2.0/24` | `us-east-1b` | Internet Gateway (IGW) | Application Load Balancer (ALB), NAT Gateway 2 |
| **Private Subnet 1** | `10.0.11.0/24` | `us-east-1a` | NAT Gateway 1 (Egress only) | Swarm Manager Node, Swarm Worker Node 1 |
| **Private Subnet 2** | `10.0.12.0/24` | `us-east-1b` | NAT Gateway 2 (Egress only) | Swarm Worker Node 2, Database Volume Store |

### Traffic Ingress Flow
1. Client requests enter through **Route 53 / Anycast DNS** to the **Application Load Balancer (ALB)**.
2. The ALB terminates TLS/HTTPS, inspects HTTP headers, evaluates health checks (`/health`), and routes traffic across private subnet targets on port 80.
3. Swarm Ingress Routing Mesh accepts the traffic on any node and routes it internally via VXLAN encapsulation to active application container replicas.

### Traffic Egress Flow
1. Compute nodes initiate outbound traffic (e.g., package updates, container image pulls from GitHub Container Registry, AWS API calls) through private routing tables.
2. Private route tables direct `0.0.0.0/0` traffic to the local Availability Zone's NAT Gateway.
3. NAT Gateways perform Network Address Translation and forward outbound requests to the Internet Gateway.

---

## 4. Docker Swarm Cluster Topology

![Docker Swarm Cluster Topology](architecture/swarm_cluster_topology.svg)

### Control Plane & Consensus
- **Swarm Manager**: Executes the Raft Consensus algorithm (port 2377). Maintains the authoritative cluster state, service definitions, internal DNS, and ingress load balancing configurations.
- **Raft State Durability**: Stored on an encrypted EBS root volume with automated state snapshots sent to AWS S3.

### Overlay Networking (Software-Defined Networks)
Docker Swarm provides isolated virtual overlay networks across nodes using VXLAN tunneling on UDP port 4789:
1. `frontend-net`: Connects Nginx reverse proxy to the backend API microservice.
2. `backend-net`: Connects backend API to internal datastores (PostgreSQL, Redis). Public reverse proxy cannot communicate directly with databases.
3. `monitoring-net`: Connects Prometheus and Loki to cAdvisor, Node Exporter, and application `/metrics` endpoints.

---

## 5. Security Perimeter & Firewall Matrix

| Security Group | Ingress Source | Ports / Protocol | Purpose |
|:---|:---|:---|:---|
| **`alb-sg`** | `0.0.0.0/0` | `80/TCP`, `443/TCP` | Public web ingress |
| **`swarm-manager-sg`** | `alb-sg` | `80/TCP`, `8080/TCP` | Load balancer traffic dispatch |
| **`swarm-manager-sg`** | `swarm-worker-sg` & Self | `2377/TCP` | Swarm cluster management & Raft consensus |
| **`swarm-manager-sg`** | `swarm-worker-sg` & Self | `7946/TCP`, `7946/UDP` | Swarm node discovery & gossip |
| **`swarm-manager-sg`** | `swarm-worker-sg` & Self | `4789/UDP` | Overlay network VXLAN traffic |
| **`swarm-worker-sg`** | `alb-sg` | `80/TCP`, `8080/TCP` | Load balancer traffic dispatch |
| **`monitoring-sg`** | Bastion / Office CIDR | `3000/TCP`, `9090/TCP` | Grafana UI & Prometheus UI |
| **`swarm-nodes`** | `monitoring-sg` | `9100/TCP`, `8080/TCP` | Node Exporter & cAdvisor scrapers |

---

## 6. Observability & CI/CD Pipeline

![CI/CD & Observability Pipeline](architecture/cicd_and_monitoring_pipeline.svg)

1. **Continuous Integration**:
   - Automated triggers on Git push to `main`.
   - Python unit testing via `pytest`, Terraform validation via `terraform fmt` and `terraform validate`.
   - Security scanning of infrastructure code and container images using **Trivy** and **Gitleaks**.
2. **Continuous Deployment**:
   - Multi-stage Docker build producing non-root container images published to GitHub Container Registry.
   - Zero-downtime rolling update dispatched to Swarm (`start-first` order, 15s delay, automatic rollback upon health check failure).
3. **Observability Stack**:
   - **Prometheus**: Polls time-series metrics from nodes and microservices every 15s.
   - **Grafana**: Visualizes real-time RED metrics, cluster CPU/memory usage, and hardware trends.
   - **Loki & Promtail**: Centralized log streaming and aggregation for all container output.
