#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated PostgreSQL Database Backup with Encryption & S3 Push
# ==============================================================================

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/backups/enterprise-db"
BACKUP_FILE="${BACKUP_DIR}/enterprise_db_${TIMESTAMP}.sql.gz"
ENCRYPTED_FILE="${BACKUP_FILE}.enc"
S3_BUCKET="${S3_BACKUP_BUCKET:-enterprise-cloud-prod-backups}"
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

echo "=== [1/5] Dumping PostgreSQL Database ==="
# Find postgres container ID in Swarm
CONTAINER_ID=$(docker ps -q -f name="enterprise_postgres" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
  echo "Error: Postgres container not found on this node."
  exit 1
fi

docker exec "$CONTAINER_ID" pg_dump -U enterprise_user enterprise_db | gzip > "$BACKUP_FILE"
echo "Database dump generated: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"

echo "=== [2/5] Encrypting Backup with AES-256-CBC ==="
ENCRYPTION_KEY="${BACKUP_ENCRYPTION_KEY:-SuperSecretDisasterRecoveryKey2026!}"
openssl enc -aes-256-cbc -salt -pbkdf2 -in "$BACKUP_FILE" -out "$ENCRYPTED_FILE" -pass pass:"$ENCRYPTION_KEY"
rm -f "$BACKUP_FILE" # Remove unencrypted raw dump

echo "=== [3/5] Calculating SHA-256 Checksum ==="
sha256sum "$ENCRYPTED_FILE" > "${ENCRYPTED_FILE}.sha256"

echo "=== [4/5] Uploading Encrypted Archive to AWS S3 ==="
if command -v aws >/dev/null 2>&1; then
  aws s3 cp "$ENCRYPTED_FILE" "s3://${S3_BUCKET}/database/$(basename "$ENCRYPTED_FILE")" --sse AES256
  aws s3 cp "${ENCRYPTED_FILE}.sha256" "s3://${S3_BUCKET}/database/$(basename "$ENCRYPTED_FILE").sha256"
  echo "Backup successfully uploaded to s3://${S3_BUCKET}/database/"
else
  echo "AWS CLI not found. Backup stored locally at $ENCRYPTED_FILE"
fi

echo "=== [5/5] Purging Local Backups Older Than ${RETENTION_DAYS} Days ==="
find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -exec rm -f {} \;
echo "Backup pipeline execution finished successfully at $(date)."
