#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Enterprise Cloud Local Simulation & Testing Playground
# Quickly initializes local Swarm, builds images, and starts the full environment
# ==============================================================================

echo "=================================================="
echo "Enterprise Cloud & DevOps Local Playground Setup"
echo "=================================================="

# Check Docker status
if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running. Please launch Docker Desktop or start docker.service."
  exit 1
fi

# Step 1: Initialize local Swarm mode if inactive
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')
if [ "$SWARM_STATUS" != "active" ]; then
  echo "[1/4] Initializing single-node Docker Swarm..."
  docker swarm init --advertise-addr 127.0.0.1
else
  echo "[1/4] Docker Swarm is already active."
fi

# Step 2: Create Overlay Networks
echo "[2/4] Ensuring overlay networks exist..."
for NET in frontend-net backend-net monitoring-net; do
  if ! docker network ls --filter name="^${NET}$" --format '{{.Name}}' | grep -q "^${NET}$"; then
    docker network create --driver overlay --attachable "${NET}"
  fi
done

# Step 3: Create Secrets
echo "[3/4] Ensuring cluster secrets exist..."
if ! docker secret inspect db_password >/dev/null 2>&1; then
  echo "local_dev_secret_db_2026" | docker secret create db_password -
fi

# Step 4: Build Local API Image
echo "[4/4] Building microservice container image..."
docker build -t enterprise-cloud-api:latest ../app

echo "=================================================="
echo "Local Environment Ready!"
echo "Deploy the stack now using:"
echo "  cd ../docker-swarm && ./deploy-stack.sh"
echo ""
echo "Access Points after deployment:"
echo "  - Application & API:  http://localhost"
echo "  - Health Check:       http://localhost/health"
echo "  - Prometheus Metrics: http://localhost:9090"
echo "  - Grafana Dashboards: http://localhost:3000 (user: admin / pass: admin_secure_cloud)"
echo "  - Swarm Visualizer:   http://localhost:8088"
echo "=================================================="
