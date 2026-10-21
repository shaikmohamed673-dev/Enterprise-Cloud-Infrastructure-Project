# Teach Me: Viva & Interview Q&A Preparation (35 Questions)

These are the exact questions evaluators, professors, and internship mentors ask — with complete model answers you can explain confidently.

---

## Category 1: Project Overview Questions

### Q1. "Tell me about your project in 2 minutes."
> "I built an enterprise cloud infrastructure automation system on AWS. I used Terraform as Infrastructure as Code to provision a secure multi-availability-zone VPC network, Application Load Balancer, and Docker Swarm compute cluster. Docker Swarm orchestrates containerized microservices with zero-downtime rolling deployments and automatic self-healing. GitHub Actions handles the full CI/CD pipeline — code testing, security scanning, container image building, and automated deployment. Prometheus and Grafana provide real-time monitoring with production alert rules. Finally, encrypted database backups are automated to AWS S3 for disaster recovery."

---

### Q2. "What is the main problem this project solves?"
> "It solves four enterprise problems simultaneously: (1) Infrastructure drift and manual configuration errors — solved by Terraform IaC which encodes the entire infrastructure as versioned code. (2) Single points of failure — solved by distributing everything across two AWS availability zones with automatic failover. (3) Deployment downtime — solved by Docker Swarm's `start-first` rolling update strategy. (4) Lack of visibility — solved by the Prometheus and Grafana observability stack."

---

### Q3. "Why did you choose AWS over other cloud providers?"
> "AWS has the largest global infrastructure footprint with 33 regions and 105 availability zones as of 2026. For this enterprise use case, key AWS services like EC2 Auto Scaling, Application Load Balancer, VPC isolation, and S3 backup storage provide a complete, integrated ecosystem. AWS Systems Manager Session Manager was critical for enabling secure administrative access to private EC2 instances without opening any inbound SSH ports."

---

## Category 2: Terraform Questions

### Q4. "What is Infrastructure as Code and why is it important?"
> "Infrastructure as Code means you define your cloud resources — servers, networks, load balancers — in text configuration files rather than clicking buttons in a cloud console. The benefits are: reproducibility (you can spin up the exact same infrastructure in 5 minutes), version control (every change is tracked in Git), disaster recovery (if the entire cloud region fails, run one Terraform command in a different region to rebuild everything), and collaboration (teams review infrastructure changes as code pull requests before they affect production)."

---

### Q5. "What is a Terraform module?"
> "A module is a reusable, self-contained package of Terraform resources. Instead of copying the same VPC code into every environment, we write it once in `terraform/modules/vpc/` and call it from both `environments/prod/` and `environments/staging/` with different variable values. This follows the DRY principle — Don't Repeat Yourself."

### Q6. "Explain terraform init, plan, apply and destroy."
> "`terraform init` downloads the required providers (AWS plugin) and initializes the local working directory. `terraform plan` generates a speculative execution plan showing exactly what changes will be made — it reads the current state and compares it to the desired configuration, displaying 'will create', 'will modify', or 'will destroy' for each resource. `terraform apply` executes the plan against the real AWS API to provision infrastructure. `terraform destroy` tears down everything Terraform created, cleaning up resources and avoiding ongoing cloud costs."

---

### Q7. "What is a Terraform state file? Why is it important?"
> "Terraform maintains a `.tfstate` file that records the real-world IDs of every resource it has created — for example, which EC2 instance ID corresponds to the manager node. Without the state file, Terraform cannot know what already exists and would try to create duplicate resources. In production, the state file is stored remotely in an S3 bucket with DynamoDB locking, preventing two engineers from applying changes simultaneously."

---

### Q8. "How did you handle sensitive values like passwords in Terraform?"
> "Sensitive values — like database passwords and AWS credentials — are never hardcoded in Terraform files. AWS credentials come from the local `~/.aws/credentials` file or IAM instance roles. Database passwords are managed as Docker Swarm encrypted secrets, injected into containers at runtime through tmpfs memory mounts. The `.gitignore` file explicitly excludes `*.tfvars` and `*.pem` files from being committed to Git."

---

## Category 3: Docker & Docker Swarm Questions

### Q9. "What is Docker and what problem does it solve?"
> "Docker packages an application and all its dependencies — Python version, libraries, OS packages — into a portable container image. The container runs identically on any machine: a developer's laptop, a staging server, or a production cloud instance. This eliminates the classic 'it works on my machine' problem. Before containers, deploying Python applications meant manually matching library versions across environments, which caused unexpected runtime failures."

---

### Q10. "Explain Docker Swarm in simple terms."
> "Docker Swarm is Docker's built-in cluster orchestration system. Imagine you have 3 servers. Swarm turns them into one logical cluster with a brain (the Manager Node) that decides which server runs each container. When you say 'I want 3 copies of my API running', Swarm distributes them across all nodes, monitors their health, and automatically replaces any container that crashes. It also provides a built-in virtual load balancer — incoming traffic to port 80 on any node gets routed to an available API container automatically, regardless of which server it's on."

---

### Q11. "What is the difference between `docker run` and `docker service create`?"
> "`docker run` starts a single container on the current machine. If that container crashes, it stays dead. `docker service create` instructs Swarm to maintain a desired number of replicas cluster-wide. If a container dies, Swarm immediately reschedules a replacement on a healthy node. Services also support rolling updates, resource limits, and placement constraints — features missing from bare `docker run`."

---

### Q12. "Explain Docker Swarm rolling updates — how does zero-downtime work?"
> "When we update a service, Swarm uses the `update_config` settings. With `order: start-first`, Swarm launches the new container version first. The new container must pass the health check probe (`GET /health/liveness`) returning HTTP 200. Only after the new container is verified healthy does Swarm stop the old container and move on to the next replica. Combined with `parallelism: 1` (updating one at a time), there are always healthy replicas serving traffic throughout the entire update — users experience zero downtime."

---

### Q13. "What are Docker Overlay Networks and why do we have three of them?"
> "Overlay networks are software-defined virtual networks that span across all Swarm nodes using VXLAN tunneling (UDP port 4789). We use three separate networks for security isolation: `frontend-net` connects Nginx to the API service — public-facing communication. `backend-net` connects the API to the database (PostgreSQL) and cache (Redis) — internal-only, completely hidden from the internet. `monitoring-net` connects Prometheus and cAdvisor to collect metrics — isolated from application traffic. Nginx cannot directly communicate with the database because they share no common network. This is micro-segmentation."

---

### Q14. "What are Docker Secrets? Why not use environment variables?"
> "Docker Secrets store sensitive values — passwords, API keys, TLS certificates — in the Raft distributed database (encrypted at rest). They are mounted into containers as files at `/run/secrets/` using tmpfs (in-memory filesystem). Unlike environment variables, secrets are: (1) not visible in `docker inspect` output, (2) not written to disk, (3) not transmitted in Docker API responses, (4) only available to services specifically granted access. This prevents credential leakage through logs, monitoring systems, or debugging tools."

---

### Q15. "Why did you choose Docker Swarm instead of Kubernetes?"
> "Docker Swarm is the right tool for medium-scale enterprise workloads where operational simplicity matters. Kubernetes requires dedicated control-plane components consuming 2-4GB RAM: API server, etcd, controller manager, scheduler, and CoreDNS. Swarm's control plane is built into Docker Engine — zero additional overhead. Swarm uses the same `docker-compose` YAML format with minimal extensions, shortening the learning curve significantly. For a company running 20-50 services across 3-10 nodes, Swarm provides full rolling updates, ingress routing, health checking, and auto-recovery — everything needed without Kubernetes complexity."

---

## Category 4: CI/CD Questions

### Q16. "Explain what happens step by step when you push code to GitHub."
> "When code is pushed to the `main` branch: (1) GitHub Actions triggers `app-ci-cd.yml`. (2) Python dependencies are installed and `pytest` runs all unit tests — if any test fails, the pipeline stops immediately. (3) The application Docker image is built. (4) Trivy scans the built image for OS and library vulnerabilities, reporting Critical and High CVEs. (5) The verified image is tagged with the Git commit SHA and pushed to GitHub Container Registry. (6) The deploy step SSH-connects to the Swarm Manager and runs `docker service update`, triggering a zero-downtime rolling update."

---

### Q17. "What is Trivy and why is it used?"
> "Trivy is an open-source vulnerability scanner created by Aqua Security. It scans container images and Terraform IaC files against the National Vulnerability Database (NVD) and CVE databases to identify known security weaknesses. Running it in CI means every single Docker image is audited before deployment — if a dependency has a critical unpatched vulnerability, the pipeline flags it, preventing vulnerable code from reaching production."

---

### Q18. "What is the difference between CI and CD?"
> "CI — Continuous Integration — is the practice of automatically testing every code change to verify it doesn't break existing functionality. It runs fast — typically under 5 minutes. CD — Continuous Deployment — is the practice of automatically delivering verified code to production without manual intervention. CI builds confidence that the code is correct; CD automates the delivery so the team can ship changes multiple times per day instead of once per quarter."

---

## Category 5: Monitoring Questions

### Q19. "Explain the Prometheus pull model."
> "Prometheus uses a pull model — it periodically sends HTTP GET requests to each monitored target's `/metrics` endpoint and fetches the current metric values. This is the opposite of push-based systems where agents send data to a central server. Pull is advantageous because: (1) Prometheus controls the scrape rate, preventing metric floods, (2) if a target goes down, Prometheus immediately knows because the scrape fails, (3) targets don't need to know where the monitoring server is."

---

### Q20. "What are the RED metrics?"
> "RED stands for Rate, Errors, Duration — the three key metrics for any service: **Rate** is how many requests per second the service is processing (`sum(rate(enterprise_http_requests_total[1m]))`). **Errors** is the percentage of requests that result in 5xx errors (`rate(enterprise_http_requests_total{status_code=~\"5..\"}[1m])`). **Duration** is the distribution of response times, specifically the 95th percentile (`histogram_quantile(0.95, ...)`)."

---

### Q21. "What is cAdvisor and how is it different from Node Exporter?"
> "Node Exporter measures **host-level** metrics — the underlying Linux OS: CPU cores, total RAM, disk partitions, network interfaces. It runs once per physical or virtual machine. cAdvisor (Container Advisor) measures **container-level** metrics — per-container CPU throttling, memory working set, network I/O inside Docker namespaces. Both run as global Swarm services (one copy on every node). Together they give complete visibility: Node Exporter tells you if the server is overloaded; cAdvisor tells you which specific container is causing it."

---

### Q22. "What is Loki? How does it compare to Elasticsearch?"
> "Loki is a horizontally scalable log aggregation system optimized for Kubernetes and Docker workloads. Unlike Elasticsearch, which indexes the full content of every log line (expensive on storage and CPU), Loki only indexes log **labels** (service name, hostname, log level) and stores the raw log text as compressed chunks. This makes Loki 10-100x more cost-efficient for pure log storage while still providing fast query results for typical debugging queries."

---

## Category 6: Security Questions

### Q23. "Why are all EC2 compute instances in private subnets?"
> "Placing servers in private subnets means they have no public IP address and cannot be directly reached from the internet — even if a port is open. The only way traffic reaches them is through the Application Load Balancer, which only forwards requests to approved ports and passes health checks. This eliminates an entire class of attacks: port scanning, SSH brute-force, direct exploitation of service vulnerabilities. Outbound internet access (for package updates and Docker image pulls) routes through NAT Gateways in public subnets."

---

### Q24. "Explain the IAM role attached to the EC2 instances. Why not use access keys?"
> "The EC2 instances are assigned an IAM instance role — `enterprise-cloud-prod-swarm-node-role`. When AWS CLI or SDK runs on these instances, it automatically retrieves temporary credentials from the EC2 metadata service (`http://169.254.169.254`). These credentials rotate automatically every hour. Using hardcoded IAM access keys is dangerous: keys can be accidentally committed to Git, logged in application output, or exposed through environment variables. Instance roles eliminate all these risks."

---

### Q25. "What is the principle of least privilege? How did you apply it?"
> "Least privilege means giving any user, process, or system component exactly the permissions it needs — no more. In this project: The Swarm EC2 IAM role has permission to write only to the specific backup S3 bucket, not all S3 buckets. The S3 bucket policy denies all requests that don't use HTTPS. Security group rules allow only the exact ports needed for each service. Containers run as non-root UID 10001. The Docker daemon is configured with `no-new-privileges: true`, preventing privilege escalation."

---

## Category 7: Architecture & Design Questions

### Q26. "What is High Availability and how did you achieve it?"
> "High Availability means the system continues functioning even when individual components fail. We achieved it through: Multi-AZ deployment — servers in two separate physical datacenters (`us-east-1a` and `us-east-1b`). Dual NAT Gateways — one per AZ, so if one fails the other AZ's instances still have outbound internet. Application Load Balancer — automatically routes traffic only to healthy instances, removing failed targets. Docker Swarm replicas — 3 API replicas mean 2 can fail simultaneously while the service remains fully operational. Auto Scaling Group — if a worker node dies, AWS automatically launches a replacement."

---

### Q27. "What is RPO and RTO in Disaster Recovery?"
> "RPO — Recovery Point Objective — is the maximum acceptable amount of data loss measured in time. If backups run every hour, the worst-case data loss is 1 hour. Our automated `backup-database.sh` script achieves RPO < 1 hour. RTO — Recovery Time Objective — is the maximum acceptable time to restore service after a failure. Our Terraform IaC allows us to rebuild the entire AWS infrastructure in under 15 minutes, and `restore-database.sh` restores the database in under 8 minutes, achieving RTO < 15 minutes."

---

### Q28. "How does Auto Scaling work in your project?"
> "The Worker Auto Scaling Group uses a Target Tracking Scaling Policy watching `ASGAverageCPUUtilization`. The target is 70%. When average CPU across all workers exceeds 70% for 3 minutes — indicating high traffic load — AWS CloudWatch triggers the scaling policy, which launches 1 or 2 new EC2 instances. The new instances run the worker bootstrap script, join the Swarm cluster, and Docker automatically schedules container replicas onto them. When traffic subsides and CPU drops below 40% for 10 minutes, AWS gracefully drains tasks from excess instances and terminates them."

---

### Q29. "What is the Nginx rate limiting you configured and why?"
> "Nginx rate limiting uses a `limit_req_zone` that tracks each client IP in a 10MB shared memory zone (`api_limit:10m`). The rate is 10 requests per second per IP address, with a burst queue of 20. This means: a normal user making 10 API calls per second passes through without delay. A bot trying to send 1000 requests per second gets immediately rejected with HTTP 429 Too Many Requests after the burst queue fills. This protects the backend API from DDoS attacks and brute-force authentication attempts."

---

## Category 8: Situational / Problem-Solving Questions

### Q30. "What would you do if the Swarm Manager node crashes?"
> "In our current setup, we have a single Swarm Manager. For production, best practice is 3 or 5 manager nodes for Raft quorum (the Raft consensus algorithm requires a majority — 2 out of 3, or 3 out of 5 — to elect a new leader). With our current architecture: the Terraform backup script saves the Swarm Raft state to S3. Recovery involves: (1) Terraform provisions a new Manager EC2 instance, (2) the new manager runs `docker swarm init --force-new-cluster` using the restored Raft state, (3) workers re-join using the stored SSM token. RTO: under 15 minutes."

---

### Q31. "How would you add HTTPS/TLS to this architecture?"
> "Add an ACM (AWS Certificate Manager) certificate to the ALB HTTPS listener on port 443. ACM automatically provisions and renews free TLS certificates from Amazon's CA. Configure an HTTP to HTTPS redirect listener rule on port 80. The ALB terminates TLS before forwarding plaintext traffic to backend Swarm instances inside the private subnet — the internal network never handles encrypted overhead. This offloads TLS processing from application instances to the purpose-built ALB hardware."

---

### Q32. "A Prometheus alert fires at 3 AM saying HostHighCpuLoad. What do you do?"
> "Step 1: Check the Grafana dashboard to identify which node and which containers are driving the spike. Step 2: Check the API request rate in Prometheus — is it a legitimate traffic surge? If yes, manually trigger the ASG to add capacity: `aws autoscaling set-desired-capacity --desired-capacity 5`. Step 3: If it's not traffic, check for a runaway container with `docker stats`. Step 4: If a single container is monopolizing CPU, update its resource limit: `docker service update --limit-cpu 0.5 enterprise_api`. Step 5: If the node itself is the problem, use SSM Session Manager to connect and diagnose with `top` and `iostat`."

---

### Q33. "How do you perform a rollback if a bad deployment breaks production?"
> "Docker Swarm stores the previous service configuration automatically. To instantly rollback: `docker service rollback enterprise_api`. Swarm reverses the rolling update, restoring the previous container image and configuration. This takes approximately 30 seconds — the same time as a forward deployment. In our GitHub Actions pipeline, the update step is also configured with `failure_action: rollback`, meaning if health checks fail during automated deployment, Swarm automatically rolls back without human intervention."

---

### Q34. "How would you scale this to handle 10 million users?"
> "Several enhancements: (1) Migrate from Docker Swarm to Amazon ECS Fargate or EKS for horizontal pod autoscaling. (2) Add AWS CloudFront as a CDN in front of the ALB to serve cacheable content from 400+ edge locations. (3) Replace single PostgreSQL with Amazon RDS Aurora Multi-AZ with read replicas. (4) Add ElastiCache (managed Redis) with replication groups. (5) Implement application-level caching with cache headers and ETags. (6) Add AWS WAF (Web Application Firewall) in front of CloudFront to block SQL injection and XSS. (7) Scale ASG workers to 20-50 instances with mixed Spot/On-Demand instance strategy."

---

### Q35. "What would you improve if you had more time?"
> "Three key improvements: (1) Add Terraform remote state backend using S3 + DynamoDB state locking so multiple team members can work on infrastructure simultaneously without conflicts. (2) Replace the single Swarm Manager with a 3-manager Raft quorum for true manager high availability. (3) Integrate Alertmanager with Grafana to send automated PagerDuty or Slack notifications when Prometheus alerts fire, completing the production on-call pipeline."
