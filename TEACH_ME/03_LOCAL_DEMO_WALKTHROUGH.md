# Teach Me: Hands-On Local Demo Walkthrough

This guide walks you through running the **entire project live** on your own Windows PC with Docker Desktop — no AWS account or cloud billing needed.

> **Prerequisite**: Docker Desktop must be running. Open Docker Desktop and make sure the whale icon is visible in the system tray.

---

## Phase 1: Start Docker Swarm Mode (1 minute)

Open **PowerShell** (or Git Bash) and run:

```powershell
# Navigate to the project
cd "C:\Users\shaik\OneDrive\Desktop\cloud project 1"

# Check Docker is running
docker info

# Initialize single-node Swarm
docker swarm init --advertise-addr 127.0.0.1
```

**What you'll see:**
```text
Swarm initialized: current node (v89s0...) is now a manager.
```

**What this does:** Turns your local PC into a single-node Docker Swarm cluster. In production on AWS, we'd have 3 nodes (1 manager + 2 workers), but locally 1 node is enough for demo purposes.

---

## Phase 2: Create Overlay Networks & Secrets (30 seconds)

```powershell
# Create the isolated virtual networks
docker network create --driver overlay --attachable frontend-net
docker network create --driver overlay --attachable backend-net
docker network create --driver overlay --attachable monitoring-net

# Create the database password secret (never stored as plain text!)
echo "demo_secure_password_2026" | docker secret create db_password -
```

**During your demo say:** *"In production on AWS, these networks span across multiple EC2 instances using VXLAN tunneling on port 4789. Docker secrets encrypt credentials and inject them into container memory — they never appear in environment variables or logs."*

---

## Phase 3: Build the Application Image (2 minutes)

```powershell
# Build the multi-stage Docker image
docker build -t enterprise-cloud-api:latest app/
```

Watch the two-stage build:
- **Stage 1 (builder)**: Installs compilers and builds Python wheels
- **Stage 2 (runtime)**: Copies only the compiled wheels into a clean minimal image

When done, check the image size:
```powershell
docker images enterprise-cloud-api
```

**During your demo say:** *"Multi-stage builds reduce image size by over 80% by discarding compilers and build tools. Our final image is approximately 130MB versus 1.2GB if we used a single stage. Smaller images = faster deployments and smaller attack surface."*

---

## Phase 4: Deploy the Monitoring Stack (1 minute)

```powershell
cd docker-swarm
docker stack deploy -c monitoring-stack.yml monitoring
```

Verify services are starting:
```powershell
docker stack services monitoring
```

Wait ~30 seconds for all replicas to show `1/1`:
```text
ID        NAME                  MODE       REPLICAS  IMAGE
xxx       monitoring_prometheus  replicated 1/1       prom/prometheus:v2.51.0
xxx       monitoring_grafana     replicated 1/1       grafana/grafana:10.4.1
xxx       monitoring_cadvisor    global     1/1       gcr.io/cadvisor/cadvisor
xxx       monitoring_node-exporter global  1/1       prom/node-exporter:v1.7.0
xxx       monitoring_loki        replicated 1/1       grafana/loki:2.9.4
xxx       monitoring_promtail    global     1/1       grafana/promtail:2.9.4
```

---

## Phase 5: Deploy the Application Stack (1 minute)

```powershell
docker stack deploy -c app-stack.yml enterprise
```

Check service health:
```powershell
docker stack services enterprise
```

Expected output after ~60 seconds:
```text
ID        NAME                       MODE       REPLICAS  PORTS
xxx       enterprise_nginx-proxy      replicated 2/2       *:80->80/tcp
xxx       enterprise_api             replicated 3/3
xxx       enterprise_redis           replicated 1/1
xxx       enterprise_postgres        replicated 1/1
xxx       enterprise_visualizer      replicated 1/1       *:8088->8080/tcp
```

---

## Phase 6: Live Demo Access Points (Show These!)

Open these in your browser:

| Demo Point | URL | What to Show |
|:---|:---|:---|
| **1. API Root** | `http://localhost/` | Node hostname, version, uptime — changes per replica! |
| **2. Health Check** | `http://localhost/health` | Deep health probe showing memory, CPU, DB status |
| **3. API Data** | `http://localhost/api/v1/items` | CRUD data endpoint |
| **4. Prometheus Metrics** | `http://localhost/metrics` | Raw Prometheus metrics output |
| **5. Prometheus UI** | `http://localhost:9090` | Run a live PromQL query! |
| **6. Grafana Dashboard** | `http://localhost:3000` | Login: admin / admin_secure_cloud |
| **7. Swarm Visualizer** | `http://localhost:8088` | Shows container placement on nodes |

### Live PromQL Queries to Run in Prometheus (`http://localhost:9090`):
```promql
# Request throughput per second
sum(rate(enterprise_http_requests_total[1m]))

# p95 response latency
histogram_quantile(0.95, sum(rate(enterprise_http_request_duration_seconds_bucket[5m])) by (le))

# Container memory usage
container_memory_usage_bytes{name!=""}
```

---

## Phase 7: Show Zero-Downtime Deployment (Impressive Demo!)

In one terminal, run a loop to simulate continuous traffic:
```powershell
# Keep hitting the API while we deploy (shows zero downtime)
for ($i = 1; $i -le 60; $i++) {
    $result = Invoke-WebRequest -Uri "http://localhost/health" -UseBasicParsing
    Write-Host "$i : $($result.StatusCode) OK"
    Start-Sleep 1
}
```

In a second terminal, trigger a rolling update:
```powershell
docker service update --image enterprise-cloud-api:latest enterprise_api
```

**Watch the first terminal**: every request continues returning `200 OK` with zero interruption!

**During your demo say:** *"Docker Swarm uses a `start-first` rolling update strategy. It launches the new container, waits until it passes health checks, routes traffic to it, and only then terminates the old container. This guarantees zero downtime for end users during every deployment."*

---

## Phase 8: Show Self-Healing (Resilience Demo!)

```powershell
# Kill one of the API containers
$container = docker ps --filter "name=enterprise_api" -q | Select-Object -First 1
docker kill $container

# Watch Swarm immediately detect and replace it
docker service ps enterprise_api
```

Within 3–5 seconds, Docker Swarm automatically reschedules and starts a replacement container.

---

## Phase 9: Show Automated Backup (Security Demo!)

```powershell
# On a Linux/Mac system or WSL:
bash scripts/backup/backup-database.sh
```

Show the encrypted output file:
```powershell
dir scripts\backup\ # (or the backup dir)
```

**During your demo say:** *"The backup script dumps the PostgreSQL database, compresses it with gzip, encrypts it with AES-256-CBC using OpenSSL, generates a SHA-256 integrity checksum, and uploads the encrypted archive to AWS S3. Even if someone intercepts the backup, they cannot read the data without the decryption key."*

---

## Phase 10: Cleanup After Demo

```powershell
# Remove application stacks
docker stack rm enterprise
docker stack rm monitoring

# Leave Swarm mode
docker swarm leave --force

# Clean up unused images and volumes
docker system prune -f
```
