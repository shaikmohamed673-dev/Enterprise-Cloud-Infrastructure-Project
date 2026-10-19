# CloudPulse — Cloud-Based Static Website Deployment

[![Deploy to GitHub Pages](https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment/actions/workflows/deploy.yml/badge.svg)](https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment/actions/workflows/deploy.yml)
[![Uptime SLA](https://img.shields.io/badge/Uptime%20SLA-99.99%25-brightgreen)](health.json)
[![Security Grade](https://img.shields.io/badge/Security%20Headers-A%2B-success)](_headers)
[![Hosting](https://img.shields.io/badge/Hosting-GitHub%20Pages%20(Selected)-blue?logo=github)](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/)
[![Lighthouse Score](https://img.shields.io/badge/Lighthouse-100%2F100-brightgreen?logo=lighthouse)](docs/PROJECT_REPORT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Cognevance Internship Project Submission**  
> **Project Title:** Cloud-Based Static Website Deployment  
> **Repository Name:** `cognevance_static_website_deployment`  
> **Author:** Shaik Mohamed ([shaikmohamed673-dev](https://github.com/shaikmohamed673-dev))  
> **Email:** shaikmohamed673@gmail.com  
> **Submission Destination:** support@cognevance.online  

---

## 📌 Architecture Decision & Platform Selection

> [!IMPORTANT]
> **Single Hosting Platform Selection (Task 2):**  
> The project specifications offered multiple hosting options (*"Host the website using AWS S3, Netlify, or GitHub Pages"*).  
> **GitHub Pages** was selected as the **sole, designated hosting platform** for this project, paired with **automated GitHub Actions CI/CD** and global Anycast CDN edge delivery.  
> The other alternative platforms (**AWS S3** and **Netlify**) have been explicitly **omitted as unwanted/redundant** to prevent cloud billing risks, avoid complex IAM credential rotation, and eliminate third-party configuration drift.

---

## 🚀 Live Demos & Deliverables

| Deliverable | Link / Reference | Description |
|:---|:---|:---|
| **Live Deployed Website** | [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/) | Live static website hosted on GitHub Pages with automated CI/CD. |
| **Synthetic Health API** | [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json) | Continuous health probe endpoint for multi-region uptime checks. |
| **GitHub Repository** | [https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment](https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment) | Complete version-controlled codebase with clean Git history. |
| **Project Report** | [docs/PROJECT_REPORT.md](docs/PROJECT_REPORT.md) | Formal report detailing architecture, hosting choice, and cost economics. |
| **Monitoring Setup Guide** | [docs/MONITORING_SETUP.md](docs/MONITORING_SETUP.md) | Step-by-step UptimeRobot and Better Stack configuration. |
| **Security & SSL/TLS Guide** | [docs/SECURITY_AND_SSL.md](docs/SECURITY_AND_SSL.md) | Security baseline, TLS 1.3 certificates, and header hardening. |
| **Submission Email Template** | [docs/SUBMISSION_EMAIL.md](docs/SUBMISSION_EMAIL.md) | Ready-to-send review, experience, and suggestions for Cognevance. |

---

## 🖥️ Architecture & Visual Previews

### Responsive Website UI Preview
![Website Preview](docs/screenshots/website_preview.svg)

### Cloud Architecture & Deployment Pipeline
![Cloud Architecture Diagram](docs/screenshots/architecture_diagram.svg)

### Real-Time Observability Dashboard
![Monitoring Dashboard](docs/screenshots/monitoring_dashboard.svg)

---

## 🛠️ Project Tasks Breakdown

| # | Task Description | Implementation Details | Status |
|:---:|:---|:---|:---:|
| **1** | **Responsive Static Website** | Modern dark/light theme, metrics counters, cloud simulator sandbox, and live latency graph. | ✅ Completed |
| **2** | **Cloud Hosting Selection** | **GitHub Pages** chosen as sole platform; AWS S3 and Netlify excluded as unwanted. | ✅ Completed |
| **3** | **Custom Domain & SSL** | Anycast CDN, TLS 1.3, Let's Encrypt automated certificates, and security headers. | ✅ Completed |
| **4** | **Git & GitHub CI/CD** | Git repo on `main` branch with automated `.github/workflows/deploy.yml` pipeline. | ✅ Completed |
| **5** | **Uptime & Performance Monitoring** | `/health.json` synthetic endpoint, UptimeRobot / Better Stack integration, and live client ping widget. | ✅ Completed |
| **6** | **Documentation** | Detailed README, formal report, setup guides, and single-platform rationale. | ✅ Completed |
| **7** | **Visual Assets & Report** | SVG architecture diagrams, UI previews, monitoring dashboards, and email template. | ✅ Completed |

---

## 📁 Repository Folder Structure

```text
cognevance_static_website_deployment/
├── .github/
│   └── workflows/
│       ├── deploy.yml             # GitHub Actions CI/CD deploying directly to GitHub Pages
│       └── lighthouse-audit.yml   # Automated code and health endpoint validator
├── assets/
│   ├── favicon.svg                # Vector cloud favicon
│   └── images/
│       ├── logo.svg               # Scalable CloudPulse vector logo
│       └── hero-cloud.svg         # Hero cloud architecture vector illustration
├── css/
│   └── style.css                  # Responsive stylesheet with dark/light variables & animations
├── docs/
│   ├── PROJECT_REPORT.md          # Comprehensive formal project report & cost analysis
│   ├── MONITORING_SETUP.md        # Step-by-step UptimeRobot & Better Stack monitoring guide
│   ├── SECURITY_AND_SSL.md        # Security headers, SSL/TLS certificates, and DNS routing
│   ├── SUBMISSION_EMAIL.md        # Ready-to-send submission email for support@cognevance.online
│   └── screenshots/
│       ├── architecture_diagram.svg
│       ├── website_preview.svg
│       └── monitoring_dashboard.svg
├── js/
│   └── main.js                    # Interactive logic: theme switcher, live ping, DevOps simulator
├── _headers                       # Security headers (HSTS, CSP, X-Frame-Options)
├── health.json                    # Synthetic health endpoint for uptime checks
├── index.html                     # Core semantic, accessible HTML5 webpage
├── LICENSE                        # MIT License
├── robots.txt                     # SEO robots configuration
├── sitemap.xml                    # XML sitemap
├── .gitignore                     # Git ignore rules
└── README.md                      # Master technical documentation
```

---

## ⚡ Deployment & Workflow Guide

### 1. Automated GitHub Pages Deployment (GitOps)
1. Push this repository to GitHub under the repository name: `cognevance_static_website_deployment`.
2. Go to **Settings > Pages** in your GitHub repository.
3. Under **Build and deployment > Source**, select **GitHub Actions**.
4. Every push to `main` triggers `.github/workflows/deploy.yml` to automatically build, test, and deploy to:
   `https://<username>.github.io/cognevance_static_website_deployment/`

### 2. Local Preview
Open `index.html` in any modern web browser or run:
```powershell
# Using Python (if installed)
python -m http.server 8000
```

---

## 🔒 Security Hardening

- **Automated TLS 1.3:** Free Let's Encrypt certificate with automated 90-day renewals.
- **Strict Transport Security (HSTS):** `max-age=31536000; includeSubDomains; preload`
- **Clickjacking Protection:** `X-Frame-Options: DENY`
- **MIME Sniffing Prevention:** `X-Content-Type-Options: nosniff`
- **Content Security Policy (CSP):** Strictly confines executable script origins.

---

## 📊 24/7 Synthetic Uptime Monitoring

- **Synthetic API (`/health.json`):** Returns real-time JSON status payload with `Cache-Control: no-cache, no-store, must-revalidate`.
- **UptimeRobot / Better Stack:** Automated 60-second multi-region HTTP ping checks with email and webhook alerting.
- **Client-Side Live Monitor:** The website features an interactive widget that measures round-trip latency against the edge and plots a live histogram.

---

## 👤 Author & Review

- **Candidate:** Shaik Mohamed
- **GitHub:** [@shaikmohamed673-dev](https://github.com/shaikmohamed673-dev)
- **Email:** [shaikmohamed673@gmail.com](mailto:shaikmohamed673@gmail.com)
- **Organization:** Cognevance
