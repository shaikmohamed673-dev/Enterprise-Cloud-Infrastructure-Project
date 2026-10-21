#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Join Worker Node to Docker Swarm Cluster
# Usage: ./join-worker.sh <MANAGER_IP> <WORKER_JOIN_TOKEN>
# ==============================================================================

MANAGER_IP="${1:-}"
TOKEN="${2:-}"

if [ -z "$MANAGER_IP" ] || [ -z "$TOKEN" ]; then
  echo "Usage: $0 <MANAGER_IP> <WORKER_JOIN_TOKEN>"
  echo "Example: $0 10.0.11.25 SWMTKN-1-49nj1cmql0jk..."
  exit 1
fi

LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "")

echo "Joining Swarm cluster at $MANAGER_IP:2377..."
if [ -n "$LOCAL_IP" ]; then
  docker swarm join --token "$TOKEN" "${MANAGER_IP}:2377" --advertise-addr "$LOCAL_IP"
else
  docker swarm join --token "$TOKEN" "${MANAGER_IP}:2377"
fi

echo "Successfully joined the Swarm cluster as a worker node!"
