#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Graceful Stack Teardown & Resource Cleanup
# ==============================================================================

echo "=================================================="
echo "Enterprise Cloud Stack Graceful Teardown"
echo "=================================================="

echo "--- [1/4] Scaling down application services to 0 ---"
docker service scale enterprise_api=0 2>/dev/null || true
docker service scale enterprise_nginx-proxy=0 2>/dev/null || true

echo "--- [2/4] Removing Application Stack ---"
docker stack rm enterprise 2>/dev/null || echo "Stack 'enterprise' not running."

echo "--- [3/4] Removing Monitoring Stack ---"
docker stack rm monitoring 2>/dev/null || echo "Stack 'monitoring' not running."

echo "--- Waiting 10 seconds for graceful shutdown ---"
sleep 10

echo "--- [4/4] Pruning unused containers, images, and volumes ---"
docker container prune -f
docker image prune -f
docker volume prune -f

echo "=================================================="
echo "Cleanup completed. To leave Swarm mode, run:"
echo "  docker swarm leave --force"
echo "=================================================="
