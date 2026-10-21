#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Initialize Docker Swarm Manager & Create Infrastructure Networks
# ==============================================================================

echo "=================================================="
echo "Initializing Docker Swarm Cluster Manager"
echo "=================================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running. Please start Docker first."
  exit 1
fi

# Detect primary IP address
HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "127.0.0.1")

# Check if already in swarm mode
SWARM_STATE=$(docker info --format '{{.Swarm.LocalNodeState}}')
if [ "$SWARM_STATE" = "active" ]; then
  echo "Node is already an active Swarm node."
else
  echo "Initializing Swarm with advertise address: $HOST_IP"
  docker swarm init --advertise-addr "$HOST_IP"
fi

echo "--- Overlay Networks Setup ---"
# Create Overlay Networks if they do not exist
for NET in frontend-net backend-net monitoring-net; do
  if docker network ls --filter name="^${NET}$" --format '{{.Name}}' | grep -q "^${NET}$"; then
    echo "Network ${NET} already exists."
  else
    echo "Creating overlay network: ${NET}"
    docker network create --driver overlay --attachable "${NET}"
  fi
done

echo "--- Creating Database Secret ---"
if ! docker secret inspect db_password >/dev/null 2>&1; then
  openssl rand -base64 24 | docker secret create db_password -
  echo "Created Swarm secret: db_password"
else
  echo "Secret db_password already exists."
fi

echo "=================================================="
echo "Cluster Initialized Successfully!"
echo "Worker Join Token:"
docker swarm join-token worker
echo "=================================================="
