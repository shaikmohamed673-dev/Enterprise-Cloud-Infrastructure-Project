# Teach Me: Architecture Diagrams Explained (Annotated Walkthrough)

This guide walks you through each architecture diagram — what every element means and what to say when presenting it.

---

## Diagram 1: AWS Cloud Infrastructure (`docs/architecture/aws_cloud_architecture.svg`)

### How to Walk Through This Diagram in a Presentation

**Start from the left side (Internet) and move right:**

> *"On the far left, we have public internet users. Their requests first hit the Internet Gateway — think of this as the front door of our entire cloud network."*

**Point to the VPC boundary:**
> *"Everything inside this blue border is our Virtual Private Cloud — a completely isolated, private network on AWS. Nothing can enter or exit without our permission."*

**Point to the Public Subnet / ALB section:**
> *"Inside the VPC, the first layer is the Public Subnet. Here we have two things: the Application Load Balancer, and NAT Gateways. The ALB is the only component that accepts incoming internet traffic — everything else is hidden. The ALB checks if backend servers are healthy and then distributes requests across them."*

**Point to the NAT Gateways:**
> *"The NAT Gateways allow servers in the private subnet to access the internet for outbound requests — like downloading Docker images or software updates — without being accessible from inbound internet traffic. We have two NAT Gateways, one per Availability Zone, for redundancy."*

**Point to the Private Subnet section:**
> *"The second layer is the Private Subnet. This is where our Docker Swarm Manager and Worker nodes live. They have no public IP address — they cannot be reached directly from the internet. The only traffic that reaches them comes from the ALB."*

**Point to the internal services box:**
> *"Inside the cluster, containers communicate through encrypted overlay networks. The API service talks to Redis for caching and PostgreSQL for data storage — none of which is ever exposed to the outside world."*

**Point to S3 and Management box on the left:**
> *"On the bottom-left, the S3 bucket stores encrypted database backups. Below it, AWS Systems Manager provides secure admin access to the private EC2 instances without opening any SSH ports."*

---

## Diagram 2: Docker Swarm Cluster Topology (`docs/architecture/swarm_cluster_topology.svg`)

### How to Walk Through This Diagram

**Point to the blue bar at the top:**
> *"The Swarm Ingress Routing Mesh at the top is Docker's built-in load balancer. Any request to port 80 on ANY node in the cluster — regardless of which server — gets automatically routed to an active API container. This is transparent to the caller."*

**Point to the Manager column:**
> *"The Manager Node is the cluster's brain. It runs the Raft consensus algorithm on port 2377, maintains the authoritative cluster state, and makes scheduling decisions. It also runs the monitoring stack — Prometheus, Grafana, and the Swarm Visualizer."*

**Point to the Worker columns:**
> *"Worker Node 1 runs two Nginx proxy replicas and two API replicas. Worker Node 2 runs a third API replica, the PostgreSQL database, and Promtail for log shipping. Both workers run cAdvisor and Node Exporter as global services — one instance per node."*

**Explain the networks:**
> *"The yellow lines connecting containers represent overlay networks. Nginx only connects to the API via `frontend-net`. The API connects to Redis and PostgreSQL via `backend-net`. Prometheus scrapes all metrics via `monitoring-net`. These three networks are completely isolated from each other — this is micro-segmentation."*

---

## Diagram 3: CI/CD & Observability Pipeline (`docs/architecture/cicd_and_monitoring_pipeline.svg`)

### How to Walk Through This Diagram

**Point to the CI/CD lane (top section):**
> *"The top half shows the automated CI/CD pipeline. When a developer pushes code to GitHub, it triggers this 5-stage pipeline automatically."*

**Walk through each step:**
> *"Step 1: Git Push — code is committed. Step 2: Lint and Unit Tests — `pytest` runs all automated tests and `terraform validate` checks IaC syntax. Step 3: Security Scan — Trivy scans both the Terraform code and the Docker container image for known CVEs. Step 4: Build and Push — the verified Docker image is built using multi-stage builds and published to GitHub Container Registry with an immutable SHA tag. Step 5: Rolling Deploy — Docker Swarm performs a zero-downtime rolling update using `start-first` order."*

**Point to the Observability lane (bottom section):**
> *"The bottom half shows the monitoring architecture. On the left, three types of exporters — Node Exporter, cAdvisor, and the custom FastAPI `/metrics` endpoint — continuously expose metrics. In the middle, Prometheus scrapes all exporters every 15 seconds and stores the data in its TSDB. On the right, Grafana reads from Prometheus and Loki to render dashboards, and fires alert notifications when rules are violated."*

---

## Key Numbers to Memorize for Your Presentation

| Fact | Value | Why It Matters |
|:---|:---:|:---|
| VPC CIDR range | `10.0.0.0/16` | 65,536 possible internal IPs — room to grow |
| Prometheus scrape interval | 15 seconds | Fast enough to catch incidents, low enough overhead |
| API replicas (normal) | 3 | Any 2 can fail, service continues |
| Nginx replicas | 2 | High-availability reverse proxy |
| Auto Scaling CPU trigger | 70% | Scales before users feel the slowness |
| Auto Scaling max workers | 6 | 6× base capacity for traffic surges |
| Docker rolling update delay | 15 seconds | Enough time for health checks to pass |
| S3 backup transition to Glacier | 30 days | Cuts storage cost by 84% |
| RTO target | 15 minutes | Industry standard for medium enterprises |
| RPO target | 1 hour | Maximum 1 hour of data at risk |
| Container non-root UID | 10001 | Security: cannot gain host root even if compromised |
| Docker daemon max log file | 50 MB × 5 files | 250 MB max log disk usage per node |
