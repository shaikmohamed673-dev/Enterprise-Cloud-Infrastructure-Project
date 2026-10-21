#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated Zero-Downtime Swarm Stack Deployment
# ==============================================================================

STACK_NAME="${1:-enterprise}"
ENV_FILE="${2:-.env}"

echo "=================================================="
echo "Deploying Enterprise Swarm Stacks: $STACK_NAME"
echo "=================================================="

# Ensure secrets exist
if ! docker secret inspect db_password >/dev/null 2>&1; then
  echo "Generating default cluster secret db_password..."
  echo "prod_secure_password_$(date +%s)" | docker secret create db_password -
fi

# Ensure monitoring network exists
if ! docker network ls --filter name="^monitoring-net$" --format '{{.Name}}' | grep -q "^monitoring-net$"; then
  echo "Creating monitoring-net overlay..."
  docker network create --driver overlay --attachable monitoring-net
fi

# Build local app image if not pulling from remote registry
if [ -f "../app/Dockerfile" ] && [ "${BUILD_LOCAL:-false}" = "true" ]; then
  echo "Building application image locally..."
  docker build -t enterprise-cloud-api:latest ../app
fi

echo "--- Deploying Observability & Monitoring Stack ---"
docker stack deploy -c monitoring-stack.yml monitoring

echo "--- Deploying Core Application Stack ---"
docker stack deploy -c app-stack.yml "$STACK_NAME"

echo "Waiting for services to stabilize..."
sleep 10

echo "=================================================="
echo "Deployment Status:"
echo "=================================================="
docker stack services "$STACK_NAME"
docker stack services monitoring
echo "=================================================="
echo "Swarm Nodes:"
docker node ls
echo "=================================================="
