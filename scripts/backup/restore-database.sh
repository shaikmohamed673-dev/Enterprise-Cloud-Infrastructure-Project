#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Disaster Recovery Database Restore from S3 / Local Backup
# Usage: ./restore-database.sh <ENCRYPTED_BACKUP_FILE_OR_S3_KEY>
# ==============================================================================

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <ENCRYPTED_BACKUP_FILE_PATH_OR_S3_URI>"
  echo "Example: $0 s3://enterprise-cloud-prod-backups/database/enterprise_db_20261021.sql.gz.enc"
  exit 1
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

LOCAL_ENC="${TEMP_DIR}/backup.sql.gz.enc"
LOCAL_GZ="${TEMP_DIR}/backup.sql.gz"

echo "=== [1/4] Retrieving Encrypted Archive ==="
if [[ "$TARGET" =~ ^s3:// ]]; then
  aws s3 cp "$TARGET" "$LOCAL_ENC"
else
  cp "$TARGET" "$LOCAL_ENC"
fi

echo "=== [2/4] Decrypting Backup ==="
ENCRYPTION_KEY="${BACKUP_ENCRYPTION_KEY:-SuperSecretDisasterRecoveryKey2026!}"
openssl enc -d -aes-256-cbc -pbkdf2 -in "$LOCAL_ENC" -out "$LOCAL_GZ" -pass pass:"$ENCRYPTION_KEY"

echo "=== [3/4] Finding PostgreSQL Container ==="
CONTAINER_ID=$(docker ps -q -f name="enterprise_postgres" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
  echo "Error: Running PostgreSQL container not found."
  exit 1
fi

echo "=== [4/4] Restoring Database Into PostgreSQL ==="
gunzip -c "$LOCAL_GZ" | docker exec -i "$CONTAINER_ID" psql -U enterprise_user -d enterprise_db

echo "=== Disaster Recovery Database Restoration Completed Successfully! ==="
