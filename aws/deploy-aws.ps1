<#
.SYNOPSIS
    Automated AWS S3 sync and CloudFront cache invalidation script.
.DESCRIPTION
    Deploys the static website to an AWS S3 bucket and triggers a global CloudFront cache purge.
.PARAMETER BucketName
    The name of the target S3 bucket.
.PARAMETER DistributionId
    The ID of the AWS CloudFront distribution to invalidate.
.EXAMPLE
    .\deploy-aws.ps1 -BucketName "cognevance-static-website" -DistributionId "E1234567890ABC"
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$BucketName = "cognevance-static-website",

    [Parameter(Mandatory=$false)]
    [string]$DistributionId = ""
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " CloudPulse - AWS S3 Deployment Automation" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Check if AWS CLI is installed
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Warning "AWS CLI is not installed or not found in system PATH."
    Write-Host "To install AWS CLI, visit: https://aws.amazon.com/cli/"
    Write-Host "Alternatively, use GitHub Actions or GitHub Pages deployment."
    exit 1
}

# 2. Sync root static assets to S3 Bucket
Write-Host "`n[1/3] Syncing files to s3://$BucketName/..." -ForegroundColor Yellow
aws s3 sync . "s3://$BucketName/" `
    --exclude ".git/*" `
    --exclude ".github/*" `
    --exclude "aws/*" `
    --exclude "docs/*" `
    --delete

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to sync files to S3 bucket."
    exit 1
}
Write-Host "✔ Files synced successfully to S3 bucket." -ForegroundColor Green

# 3. Set custom cache headers on HTML vs assets
Write-Host "`n[2/3] Setting optimized Cache-Control headers..." -ForegroundColor Yellow
aws s3 cp "s3://$BucketName/index.html" "s3://$BucketName/index.html" `
    --metadata-directive REPLACE `
    --cache-control "max-age=0, must-revalidate" `
    --content-type "text/html"

aws s3 cp "s3://$BucketName/health.json" "s3://$BucketName/health.json" `
    --metadata-directive REPLACE `
    --cache-control "no-cache, no-store, must-revalidate" `
    --content-type "application/json"

# 4. Invalidate CloudFront CDN Cache
if ($DistributionId -ne "") {
    Write-Host "`n[3/3] Invalidating CloudFront cache (Distribution: $DistributionId)..." -ForegroundColor Yellow
    aws cloudfront create-invalidation `
        --distribution-id $DistributionId `
        --paths "/*"
    Write-Host "✔ CloudFront cache invalidation initiated." -ForegroundColor Green
} else {
    Write-Host "`n[3/3] Skipped CloudFront invalidation (no DistributionId provided)." -ForegroundColor DarkGray
}

Write-Host "`nDeployment completed successfully! 🚀" -ForegroundColor Green
