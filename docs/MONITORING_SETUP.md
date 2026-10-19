# Website Uptime & Performance Monitoring Setup Guide

This guide walks through configuring end-to-end monitoring for the deployed static website.

---

## 1. Synthetic Health Endpoint Overview

The project provides an immutable health status payload at:
```http
GET /health.json
```

**Response Format:**
```json
{
  "status": "UP",
  "service": "CloudPulse Static Web Service",
  "metrics": {
    "target_uptime_sla": "99.99%",
    "avg_global_latency_ms": 32,
    "security_grade": "A+"
  }
}
```

Headers applied to this endpoint prevent CDN caching:
- `Cache-Control: no-cache, no-store, must-revalidate`
- `Access-Control-Allow-Origin: *`

---

## 2. UptimeRobot Setup (Recommended Free Tier)

1. **Sign Up / Log In**: Navigate to [https://uptimerobot.com](https://uptimerobot.com)
2. **Add New Monitor**:
   - **Monitor Type:** `HTTP(s)`
   - **Friendly Name:** `CloudPulse Static Website`
   - **URL (or IP):** `https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json`
   - **Monitoring Interval:** `5 minutes` (or `1 minute` on Pro plan)
   - **Monitor Timeout:** `30 seconds`
3. **Keyword / JSON Validation (Optional):**
   - Check for string: `"status": "UP"`
4. **Alert Contacts:**
   - Add your email (`shaikmohamed673@gmail.com`) or Discord/Slack webhook.
5. **Public Status Page:**
   - Under *Status Pages*, create a new public status page (e.g., `status.cloudpulse.io`) to showcase 100% uptime to stakeholders.

---

## 3. Better Stack / Better Uptime Setup

1. Go to [https://betterstack.com/uptime](https://betterstack.com/uptime)
2. Create an **Incident Monitor**:
   - **URL:** `https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/`
   - **Check frequency:** 3 minutes
   - **Locations:** Global (North America, Europe, Asia)
3. Set alert policy to trigger on 2 failed probes across distinct geographic locations.

---

## 4. AWS CloudWatch Metrics & Alarms (When deployed to AWS)

When hosting via AWS CloudFront, CloudWatch automatically records:
- `Requests`: Total number of requests.
- `BytesDownloaded`: Bandwidth egress.
- `4xxErrorRate`: Client error percentage.
- `5xxErrorRate`: Origin / Edge server error percentage.

### Creating 5xx Error Rate Alarm via AWS CLI:
```bash
aws cloudwatch put-metric-alarm \
    --alarm-name "CloudPulse-High-5xx-Error-Rate" \
    --metric-name 5xxErrorRate \
    --namespace AWS/CloudFront \
    --statistic Average \
    --period 300 \
    --threshold 1.0 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=DistributionId,Value=YOUR_DISTRIBUTION_ID \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:cloudpulse-alerts
```

---

## 5. Google Lighthouse Automated CI/CD Audit

To run a Lighthouse audit locally or in CI:
```bash
npx lighthouse-ci collect --url=https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/
```

Or view directly in Google Chrome DevTools:
1. Open Chrome and navigate to the website.
2. Press `F12` or `Ctrl+Shift+I` to open Developer Tools.
3. Select the **Lighthouse** tab.
4. Select Categories: **Performance, Accessibility, Best Practices, SEO**.
5. Click **Analyze page load**.
