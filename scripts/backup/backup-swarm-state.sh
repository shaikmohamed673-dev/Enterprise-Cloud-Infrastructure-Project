#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated Swarm Raft Log & State Backup to S3
# Note: Should be executed on a Swarm Manager node
# ==============================================================================

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/backups/swarm-state"
ARCHIVE_NAME="swarm_state_${TIMESTAMP}.tar.gz"
S3_BUCKET="${S3_BACKUP_BUCKET:-enterprise-cloud-prod-backups}"

mkdir -p "$BACKUP_DIR"

echo "=== Backing up Docker Swarm Raft State ==="
# Docker Swarm state resides in /var/lib/docker/swarm
if [ -d "/var/lib/docker/swarm" ]; then
  tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" -C /var/lib/docker swarm/
  echo "Swarm state archive created: ${BACKUP_DIR}/${ARCHIVE_NAME}"

  if command -v aws >/dev/null 2>&1; then
    aws s3 cp "${BACKUP_DIR}/${ARCHIVE_NAME}" "s3://${S3_BUCKET}/swarm-state/${ARCHIVE_NAME}" --sse AES256
    echo "Swarm state uploaded to S3 successfully."
  fi
else
  echo "Error: /var/lib/docker/swarm directory does not exist on this node."
  exit 1
fi
