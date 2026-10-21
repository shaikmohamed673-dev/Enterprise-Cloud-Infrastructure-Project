# Teach Me: Concepts Glossary (Plain-English Definitions)

Every technical term used in this project — explained simply.

---

## A

**ALB (Application Load Balancer)**
A smart traffic distributor from AWS. It receives incoming HTTP/HTTPS requests from the internet and distributes them across multiple backend servers. It also continuously checks server health and automatically removes unhealthy servers from the rotation. Think of it as a receptionist who directs customers to available staff members.

**ASG (Auto Scaling Group)**
An AWS service that automatically adjusts the number of EC2 virtual machines based on demand. If traffic surges, it adds machines; if traffic drops, it removes them. You define the minimum, maximum, and a rule to trigger scaling (e.g., CPU > 70%).

**AES-256 (Advanced Encryption Standard 256-bit)**
A military-grade encryption algorithm used worldwide by banks, governments, and cloud providers. In this project, database backups are encrypted with AES-256 before uploading to S3 — meaning even if someone steals the backup file, they cannot read the data without the secret key.

**AMI (Amazon Machine Image)**
A pre-packaged virtual server template in AWS. An AMI includes the operating system and pre-installed software. We use the official Ubuntu 22.04 LTS AMI from Canonical (the company that makes Ubuntu) to launch our EC2 instances.

**ASLR (Address Space Layout Randomization)**
A Linux kernel security feature that randomizes memory addresses every time a program starts. This makes it much harder for attackers to exploit buffer overflow vulnerabilities, because they cannot predict where code is located in memory.

---

## C

**cAdvisor (Container Advisor)**
An open-source monitoring tool from Google that runs inside Docker and measures per-container resource consumption: CPU percentage, memory usage, network I/O, and disk I/O. It exposes these metrics on a `/metrics` endpoint for Prometheus to scrape.

**CIDR (Classless Inter-Domain Routing)**
A notation for describing IP address ranges. `10.0.0.0/16` means: start at 10.0.0.0 and include all addresses where the first 16 bits match — giving 65,536 total addresses (10.0.0.0 to 10.0.255.255). `/24` means the first 24 bits match, giving 256 addresses.

**CI/CD (Continuous Integration / Continuous Deployment)**
CI: Automatically test every code change when it's pushed to Git. CD: Automatically deploy tested code to production without manual steps. Together they allow teams to release software updates multiple times per day with confidence.

**CloudWatch**
AWS's native monitoring and alerting service. It collects logs and metrics from AWS services. In this project, the EC2 instances run the CloudWatch Agent to ship system logs and OS metrics to CloudWatch for centralized retention.

---

## D

**DRY Principle (Don't Repeat Yourself)**
A software engineering principle meaning identical logic should be written once and reused. In Terraform, we implement this via modules — write the VPC networking code once, reference it for both `prod` and `staging` environments with different parameters.

**Docker**
A platform for running applications in isolated, lightweight containers. Each container includes the application code, its runtime, libraries, and OS dependencies. Containers share the host OS kernel but are completely isolated from each other using Linux namespaces and cgroups.

**Docker Swarm**
Docker's built-in container orchestration system. It turns multiple Docker hosts (EC2 instances) into a single logical cluster. It manages service scaling, health monitoring, load balancing, secret distribution, and rolling updates across the cluster.

---

## E

**EBS (Elastic Block Storage)**
Persistent disk storage in AWS attached to EC2 instances — similar to a USB hard drive. In this project, EC2 root volumes are gp3 EBS volumes (30 GB) with encryption enabled. The PostgreSQL database writes data to an EBS volume so data persists even if the container restarts.

**EC2 (Elastic Compute Cloud)**
AWS's virtual machine service. An EC2 instance is a server running in AWS's datacenters. We use `t3.medium` instances (2 vCPUs, 4 GB RAM) for production Swarm nodes and `t3.small` instances (2 vCPUs, 2 GB RAM) for staging.

---

## F

**Fail2ban**
A Linux intrusion prevention tool that reads log files and automatically bans IP addresses that show suspicious patterns — such as too many failed SSH login attempts. After 3 failed logins, the source IP is blocked for 1 hour.

---

## G

**Grafana**
An open-source analytics and visualization platform. It connects to data sources (Prometheus, Loki, CloudWatch) and renders interactive dashboards with graphs, gauges, alerts, and tables. Think of it as the display screen for all monitoring data.

**gzip**
A file compression algorithm. Compressing database backups with gzip before uploading to S3 reduces file sizes by 70-90%, saving storage costs and upload time.

---

## I

**IAM (Identity and Access Management)**
AWS's permission management system. Every AWS API call requires credentials — an IAM user, role, or service account. In this project, EC2 instances have an IAM Role attached, granting them permission to: (1) use SSM Session Manager, (2) push metrics to CloudWatch, (3) write backups to the S3 bucket.

**IaC (Infrastructure as Code)**
The practice of managing cloud infrastructure through machine-readable configuration files (like Terraform `.tf` files) rather than manual clicks in a web console. Infrastructure becomes versionable, reviewable, and reproducible.

**Internet Gateway (IGW)**
An AWS networking component that connects a VPC to the public internet. Resources in public subnets can send and receive traffic through the IGW. Private subnets do NOT route through the IGW — they are completely isolated from incoming internet traffic.

---

## L

**Loki**
A horizontally scalable log aggregation system by Grafana Labs. Unlike Elasticsearch, Loki only indexes log labels (not content), making it significantly more cost-efficient. It stores compressed log chunks and integrates natively with Grafana for log visualization.

---

## M

**Microservice**
A small, independently deployable application component that performs a single specific function. In this project, the FastAPI application is a microservice handling API requests. It can be scaled, updated, and restarted independently from the Nginx proxy, Redis, or PostgreSQL.

**Multi-AZ (Multi-Availability Zone)**
Deploying resources across multiple physically separated datacenters within the same AWS Region. If one datacenter loses power or has a network failure, the other AZ continues serving traffic. AWS availability zones are connected by high-speed private fiber links.

---

## N

**NAT Gateway**
Network Address Translation Gateway — allows EC2 instances in private subnets to initiate outbound internet connections (e.g., downloading software updates, pulling Docker images) without being accessible from inbound internet traffic.

**Node Exporter**
A Prometheus exporter that runs on every Linux host and exposes hardware and OS metrics: CPU utilization, memory consumption, disk I/O rates, filesystem usage, and network throughput.

---

## O

**Overlay Network**
A virtual network layer built on top of the physical network infrastructure. Docker Swarm creates overlay networks using VXLAN encapsulation (UDP port 4789) to provide seamless container-to-container communication across multiple physical hosts as if they were on the same local network.

---

## P

**Prometheus**
An open-source monitoring system and time-series database. It uses a pull model — periodically fetching metrics from HTTP `/metrics` endpoints. Stores data as timestamped numeric values and provides PromQL, a powerful query language for analyzing trends and detecting anomalies.

**PromQL**
Prometheus Query Language — a functional query language for selecting and aggregating time-series data. Example: `sum(rate(enterprise_http_requests_total[1m]))` calculates the total request throughput per second, averaged over the last 1 minute.

---

## R

**Raft Consensus Algorithm**
A distributed consensus protocol used by Docker Swarm to maintain cluster state consistency across manager nodes. All manager nodes agree on the cluster state through leader election and log replication. If the leader fails, the remaining managers elect a new leader within seconds.

**RED Method**
A monitoring methodology for microservices: **R**ate (requests per second), **E**rrors (error percentage), **D**uration (response time distribution). These three metrics together fully characterize service health from a user perspective.

**RPO (Recovery Point Objective)**
The maximum acceptable amount of data that can be lost in a disaster scenario, measured in time. If RPO is 1 hour, the system must take backups at least every hour. Our automated S3 backup achieves RPO < 1 hour.

**RTO (Recovery Time Objective)**
The maximum acceptable time to restore a system to full operation after a failure. Our Terraform + restore scripts achieve RTO < 15 minutes for complete infrastructure rebuilds.

---

## S

**S3 (Simple Storage Service)**
AWS's object storage service. Provides virtually unlimited storage for files (objects), accessible via HTTPS API. In this project used for: encrypted database backups, Swarm state archives. Features include versioning (keeps previous copies) and lifecycle policies (automatic transitions to cheaper storage tiers).

**Security Group**
An AWS virtual firewall applied to EC2 instances and other resources. Controls inbound and outbound traffic by port, protocol, and source. Unlike network ACLs (which are stateless), Security Groups are stateful — if an inbound connection is allowed, its response traffic is automatically permitted.

**SHA-256 (Secure Hash Algorithm 256-bit)**
A cryptographic hash function that produces a unique 64-character fingerprint of any file. Used in this project to verify backup integrity — if a single byte in the backup was corrupted during upload or storage, the SHA-256 checksum will not match, detecting the corruption.

**SSM (AWS Systems Manager)**
An AWS service providing secure, audited access to EC2 instances without requiring open SSH ports. SSM Session Manager creates an encrypted session through the AWS API, with all commands logged to CloudWatch. Our instances run the SSM Agent, completely eliminating port 22 from security groups.

---

## T

**Target Group**
An ALB construct that groups EC2 instances or containers that should receive traffic. The ALB routes incoming requests to the target group, which distributes them across healthy registered targets based on health check results.

**Terraform**
An open-source Infrastructure as Code tool by HashiCorp. Uses a declarative HCL (HashiCorp Configuration Language) syntax to describe desired infrastructure state. Supports 1,700+ providers including AWS, Azure, GCP, Kubernetes, GitHub, and Cloudflare.

**TLS (Transport Layer Security)**
The cryptographic protocol that secures HTTPS connections. In this project, the ALB terminates TLS (handles encryption/decryption), forwarding plaintext traffic to backend Swarm instances inside the private VPC — the internal network never processes TLS overhead.

---

## U

**UFW (Uncomplicated Firewall)**
A simplified interface to the Linux iptables firewall. UFW rules define which network ports accept incoming and outgoing connections. In `harden-node.sh`, UFW is configured to block all incoming traffic by default and only allow specific Swarm management and web ports.

---

## V

**VPC (Virtual Private Cloud)**
A logically isolated section of the AWS cloud. A VPC contains your own private network (subnets, routing tables, internet gateways) completely separated from other AWS customers. All resources in this project — EC2 instances, load balancers, NAT gateways — reside inside a single VPC (`10.0.0.0/16`).

**VXLAN (Virtual Extensible LAN)**
A network tunneling protocol (UDP port 4789) that Docker Swarm uses to implement overlay networks. VXLAN wraps container network packets inside UDP datagrams, allowing containers on different physical hosts to communicate as if they're on the same local area network.

---

## W

**Worker Node**
In Docker Swarm, worker nodes execute container workloads. They receive task scheduling assignments from the manager node, run the actual application containers, and report their status back to the manager. Workers in this project run inside AWS EC2 instances managed by an Auto Scaling Group.
