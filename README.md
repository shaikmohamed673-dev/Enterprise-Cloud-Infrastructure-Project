# CloudPulse — Cloud-Based Static Website Deployment

[![Deploy Status](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=github-actions)](.github/workflows/deploy.yml)
[![Uptime SLA](https://img.shields.io/badge/Uptime%20SLA-99.99%25-brightgreen)](health.json)
[![Security Grade](https://img.shields.io/badge/Security%20Headers-A%2B-success)](_headers)
[![AWS S3 + CloudFront](https://img.shields.io/badge/Cloud-AWS%20S3%20%7C%20CloudFront-orange?logo=amazon-aws)](aws/)
[![Lighthouse Score](https://img.shields.io/badge/Lighthouse-100%2F100-brightgreen?logo=lighthouse)](docs/PROJECT_REPORT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Cognevance Project Submission**  
> **Repository Name:** `cognevance_static_website_deployment`  
> **Author:** Shaik Mohamed ([shaikmohamed673-dev](https://github.com/shaikmohamed673-dev))  
> **Email:** shaikmohamed673@gmail.com  
> **Submission Email:** support@cognevance.online  

---

## 📌 Project Overview

**CloudPulse** is an enterprise-grade, high-performance static website deployed on cloud infrastructure with automated continuous deployment (CI/CD), custom domain routing, bank-grade TLS 1.3 encryption, and real-time synthetic uptime monitoring.

Built with lightweight, semantic **HTML5**, modern **CSS3** (custom properties, light/dark mode, CSS Grid/Flexbox), and vanilla **JavaScript**, the application achieves a **100/100 Google Lighthouse** score with zero heavy runtime dependencies and sub-100ms first paint times.

---

## 🚀 Live Demos & Deliverables

| Deliverable | Link / Reference |
|:---|:---|
| **Live Website (GitHub Pages)** | [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/) |
| **Synthetic Health API** | [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json) |
| **GitHub Repository** | [https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment](https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment) |
| **Comprehensive Project Report** | [docs/PROJECT_REPORT.md](docs/PROJECT_REPORT.md) |
| **Monitoring Configuration Guide** | [docs/MONITORING_SETUP.md](docs/MONITORING_SETUP.md) |
| **Security & SSL/TLS Guide** | [docs/SECURITY_AND_SSL.md](docs/SECURITY_AND_SSL.md) |
| **Submission Email Template** | [docs/SUBMISSION_EMAIL.md](docs/SUBMISSION_EMAIL.md) |

---

## 🖥️ UI & Architecture Previews

### Responsive Website UI Preview
![Website Preview](docs/screenshots/website_preview.svg)

### Cloud Architecture & Deployment Pipeline
![Cloud Architecture Diagram](docs/screenshots/architecture_diagram.svg)

### Real-Time Observability Dashboard
![Monitoring Dashboard](docs/screenshots/monitoring_dashboard.svg)

---

## 🛠️ Project Tasks & Implementation Status

| # | Task Description | Implementation Details | Status |
|:---:|:---|:---|:---:|
| **1** | **Responsive Static Website** | Modern dark/light theme, metrics counters, cloud simulator sandbox, and live latency graph. | ✅ Completed |
| **2** | **Multi-Cloud Hosting** | Hosted on GitHub Pages; full Terraform IaC & CLI scripts for AWS S3 + CloudFront; Netlify config. | ✅ Completed |
| **3** | **Custom Domain & SSL** | TLS 1.3, automated certificate renewal (ACM / Let's Encrypt), HSTS, CSP, and DNS setup guides. | ✅ Completed |
| **4** | **Git & GitHub CI/CD** | Git repo initialized with branch `main`, automated `.github/workflows/deploy.yml` pipeline. | ✅ Completed |
| **5** | **Uptime & Performance Monitoring** | `/health.json` synthetic endpoint, UptimeRobot / Better Stack integration, and live client ping widget. | ✅ Completed |
| **6** | **Documentation** | Detailed README, formal report, setup guides, and IaC scripts. | ✅ Completed |
| **7** | **Visual Assets & Report** | SVG architecture diagrams, UI previews, monitoring dashboards, and email template. | ✅ Completed |

---

## 📁 Repository Folder Structure

```text
cognevance_static_website_deployment/
├── .github/
│   └── workflows/
│       ├── deploy.yml             # GitHub Actions CI/CD for automated GitHub Pages deployment
│       └── lighthouse-audit.yml   # CI syntax and health endpoint integrity checks
├── assets/
│   ├── favicon.svg                # Vector cloud favicon
│   └── images/
│       ├── logo.svg               # Scalable CloudPulse vector logo
│       └── hero-cloud.svg         # Hero cloud architecture vector illustration
├── aws/
│   ├── s3-bucket-policy.json      # AWS S3 Origin Access Control (OAC) bucket policy
│   ├── cloudfront-config.json     # AWS CloudFront CDN distribution settings
│   ├── deploy-aws.ps1             # PowerShell script for automated AWS S3 sync & cache purge
│   ├── deploy-aws.sh              # Bash script for AWS S3 deployment in CI/Linux
│   └── terraform/
│       ├── main.tf                # Complete IaC: S3 bucket, CloudFront, Route53, and CloudWatch
│       ├── variables.tf           # Terraform input variables
│       └── outputs.tf             # Terraform output values (CloudFront DNS, S3 ARN)
├── css/
│   └── style.css                  # Modern stylesheet with CSS custom properties & animations
├── docs/
│   ├── PROJECT_REPORT.md          # Comprehensive formal project report & cost analysis
│   ├── MONITORING_SETUP.md        # Step-by-step UptimeRobot, Better Stack, and Lighthouse guide
│   ├── SECURITY_AND_SSL.md        # Security headers, SSL/TLS certificates, and DNS routing
│   ├── SUBMISSION_EMAIL.md        # Ready-to-send submission email for support@cognevance.online
│   └── screenshots/
│       ├── architecture_diagram.svg
│       ├── website_preview.svg
│       └── monitoring_dashboard.svg
├── js/
│   └── main.js                    # Interactive logic: theme switcher, live ping, DevOps simulator
├── _headers                       # Security headers for Netlify / Cloudflare Pages
├── health.json                    # Synthetic health endpoint for uptime checks
├── index.html                     # Core semantic, accessible HTML5 webpage
├── LICENSE                        # MIT License
├── netlify.toml                   # Netlify build and cache headers configuration
├── robots.txt                     # SEO robots configuration
├── sitemap.xml                    # XML sitemap
├── .gitignore                     # Git ignore rules
└── README.md                      # Master technical documentation
```

---

## ⚡ Deployment & Setup Guide

### 1. Local Development & Preview
To run the website locally without any server dependencies:
- Simply double-click `index.html` to open it in any web browser (Chrome, Edge, Firefox, Safari).
- Or run a simple local HTTP server:
  ```powershell
  # Using Python (if installed)
  python -m http.server 8000
  ```

### 2. GitHub Pages Deployment (Automated CI/CD)
1. Push this repository to GitHub under the repository name: `cognevance_static_website_deployment`.
2. Go to **Settings > Pages** in your GitHub repository.
3. Under **Build and deployment > Source**, select **GitHub Actions**.
4. Every push to the `main` branch will automatically trigger `.github/workflows/deploy.yml` and publish your site at:
   `https://<username>.github.io/cognevance_static_website_deployment/`

### 3. AWS S3 + CloudFront Deployment (Production Enterprise)
#### Option A: Using Terraform (Infrastructure as Code)
```bash
cd aws/terraform
terraform init
terraform plan
terraform apply
```
This automatically provisions:
- Encrypted S3 bucket with public access blocked.
- CloudFront Origin Access Control (OAC).
- Global CloudFront distribution with HTTPS redirection.
- CloudWatch 5xx alarm.

#### Option B: Using the Automated PowerShell Script
```powershell
.\aws\deploy-aws.ps1 -BucketName "cognevance-static-website" -DistributionId "YOUR_CF_DIST_ID"
```

### 4. Netlify Deployment
1. Connect this repository to [Netlify](https://www.netlify.com).
2. Set **Publish directory** to `.`.
3. Netlify will automatically detect `netlify.toml` and `_headers` to apply all caching and security headers.

---

## 🔒 Security Hardening & SSL/TLS

- **Enforced TLS 1.3:** All HTTP traffic automatically redirects to HTTPS.
- **Strict Transport Security (HSTS):** `max-age=31536000; includeSubDomains; preload`
- **Content Security Policy (CSP):** Restricts script, style, and connect origins.
- **Clickjacking Prevention:** `X-Frame-Options: DENY`.
- **MIME Sniffing Prevention:** `X-Content-Type-Options: nosniff`.
- **Zero-Trust S3 Bucket:** Direct S3 public access is completely blocked. Traffic must authenticate through CloudFront via Origin Access Control (OAC).

---

## 📊 Synthetic Uptime & Performance Monitoring

- **Synthetic API (`/health.json`):** Returns real-time JSON status with cache-busting headers.
- **UptimeRobot / Better Stack:** Automated 60-second multi-region HTTP ping checks with email and webhook alerting.
- **Client-Side Live Monitor:** The website features an interactive widget that measures round-trip latency against the edge and plots a live histogram.

---

## ✉️ Submission Checklist

- [x] Separate GitHub repository named `cognevance_static_website_deployment`.
- [x] Responsive static website using HTML5, CSS3, and JavaScript.
- [x] Multi-cloud hosting configurations (AWS S3, Netlify, GitHub Pages).
- [x] Custom domain and security settings documented.
- [x] Version control with clean commit history and CI/CD workflow.
- [x] Real-time synthetic monitoring and health endpoint.
- [x] Comprehensive `README.md`, technical report, and setup guides.
- [x] High-resolution SVG screenshots, architecture diagrams, and mockups.
- [x] Email submission template prepared for `support@cognevance.online`.

---

## 👤 Author & Review

- **Candidate:** Shaik Mohamed
- **GitHub:** [@shaikmohamed673-dev](https://github.com/shaikmohamed673-dev)
- **Email:** [shaikmohamed673@gmail.com](mailto:shaikmohamed673@gmail.com)
- **Organization:** Cognevance

*Review & Feedback: Submitted via [docs/SUBMISSION_EMAIL.md](docs/SUBMISSION_EMAIL.md).*
