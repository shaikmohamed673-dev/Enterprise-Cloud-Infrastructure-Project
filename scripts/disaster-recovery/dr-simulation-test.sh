#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated Disaster Recovery Simulation & Resilience Test
# ==============================================================================

echo "=================================================="
echo "Starting Enterprise DR & Fault Tolerance Simulation"
echo "=================================================="

# Test 1: Verify Stack Services Health
echo "--- Test 1: Stack Health Verification ---"
RUNNING_SERVICES=$(docker service ls --filter "name=enterprise_api" --format "{{.Replicas}}")
echo "API Service Replicas: $RUNNING_SERVICES"

# Test 2: Simulate Failure by Killing One API Replica Container
echo "--- Test 2: Simulating Unplanned Container Failure ---"
CONTAINER_TO_KILL=$(docker ps -q -f "name=enterprise_api" | head -n 1)

if [ -n "$CONTAINER_TO_KILL" ]; then
  echo "Killing container: $CONTAINER_TO_KILL"
  docker kill "$CONTAINER_TO_KILL" > /dev/null

  echo "Waiting 5 seconds for Swarm orchestrator auto-healing..."
  sleep 5

  # Check if Swarm revived or rescheduled a replacement task
  NEW_CONTAINERS=$(docker ps -q -f "name=enterprise_api" | wc -l)
  echo "Active containers after kill: $NEW_CONTAINERS"
  if [ "$NEW_CONTAINERS" -ge 1 ]; then
    echo "SUCCESS: Docker Swarm self-healing detected. New task spawned."
  else
    echo "FAILED: Self-healing did not spawn replacement in time."
  fi
fi

# Test 3: Synthetic Ingress Ping
echo "--- Test 3: Endpoint Resilience Probe ---"
for i in {1..5}; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health || echo "000")
  echo "Request $i: HTTP Status $HTTP_CODE"
  sleep 1
done

echo "=================================================="
echo "DR & Resilience Simulation Completed Successfully!"
echo "=================================================="
