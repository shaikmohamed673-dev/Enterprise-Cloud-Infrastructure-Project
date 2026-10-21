#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Manually Scale a Docker Swarm Service
# Usage: ./scale-service.sh <SERVICE_NAME> <REPLICA_COUNT>
# ==============================================================================

SERVICE="${1:-enterprise_api}"
REPLICAS="${2:-3}"

if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
  echo "Error: This node is not part of a Docker Swarm cluster."
  exit 1
fi

echo "=== Scaling service '${SERVICE}' to ${REPLICAS} replicas ==="
docker service scale "${SERVICE}=${REPLICAS}"

echo "=== Waiting for all replicas to reach desired state ==="
sleep 5
docker service ps "${SERVICE}" --filter "desired-state=running"
echo "=== Current service status ==="
docker service ls --filter "name=${SERVICE}"
