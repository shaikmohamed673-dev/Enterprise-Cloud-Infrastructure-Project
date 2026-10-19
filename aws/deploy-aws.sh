#!/usr/bin/env bash
# ==============================================================================
# CloudPulse - AWS S3 & CloudFront Deployment Script (Linux/macOS/CI)
# ==============================================================================

set -e

BUCKET_NAME=${1:-"cognevance-static-website"}
DISTRIBUTION_ID=${2:-""}

echo "=========================================="
echo " CloudPulse - AWS S3 Deployment"
echo " Target Bucket: s3://$BUCKET_NAME"
echo "=========================================="

if ! command -v aws &> /dev/null; then
    echo "ERROR: aws CLI is not installed or not in PATH."
    exit 1
fi

echo "[1/3] Syncing files to S3 bucket..."
aws s3 sync . "s3://$BUCKET_NAME/" \
    --exclude ".git/*" \
    --exclude ".github/*" \
    --exclude "aws/*" \
    --exclude "docs/*" \
    --delete

echo "[2/3] Applying cache control headers..."
aws s3 cp "s3://$BUCKET_NAME/index.html" "s3://$BUCKET_NAME/index.html" \
    --metadata-directive REPLACE \
    --cache-control "max-age=0, must-revalidate" \
    --content-type "text/html"

aws s3 cp "s3://$BUCKET_NAME/health.json" "s3://$BUCKET_NAME/health.json" \
    --metadata-directive REPLACE \
    --cache-control "no-cache, no-store, must-revalidate" \
    --content-type "application/json"

if [ -n "$DISTRIBUTION_ID" ]; then
    echo "[3/3] Invalidating CloudFront distribution $DISTRIBUTION_ID..."
    aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"
    echo "✔ CloudFront cache invalidation triggered."
else
    echo "[3/3] CloudFront invalidation skipped (No DISTRIBUTION_ID provided)."
fi

echo "Deployment finished successfully! 🚀"
