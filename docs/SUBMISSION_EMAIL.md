# Cognevance Project Submission Email Template

**To:** support@cognevance.online  
**Subject:** Project Submission: Cloud-Based Static Website Deployment — cognevance_static_website_deployment — Shaik Mohamed  

---

Dear Cognevance Team,

I have completed the assigned project **"Cloud-Based Static Website Deployment"** in full compliance with the submission guidelines. Below are the project repository links, deployment links, documentation, and my review, experience, and suggestions.

---

### 1. Submission Details & Links

- **Candidate Name:** Shaik Mohamed
- **GitHub Username:** [shaikmohamed673-dev](https://github.com/shaikmohamed673-dev)
- **Email:** shaikmohamed673@gmail.com
- **Project Title:** Cloud-Based Static Website Deployment
- **GitHub Repository Link:** [https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment](https://github.com/shaikmohamed673-dev/cognevance_static_website_deployment)
- **Live Deployment Link:** [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/)
- **Live Health Endpoint:** [https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json](https://shaikmohamed673-dev.github.io/cognevance_static_website_deployment/health.json)

---

### 2. Deliverables Summary

1. **Website Source Code:**
   - Production-ready, responsive static website built with semantic HTML5, CSS3 (variables, light/dark mode, CSS grid/flexbox), and vanilla JavaScript.
   - 100/100 Google Lighthouse audit score with zero framework bloat.
   - Interactive features: Live edge latency ping check, dynamic metric counters, dark/light theme switch, and an interactive DevOps simulator (traffic spikes, CDN cache invalidations, and DNS failover).

2. **Cloud Infrastructure & Deployment Configurations:**
   - **GitHub Pages:** Automated deployment via GitHub Actions (`.github/workflows/deploy.yml`).
   - **AWS S3 + CloudFront:** Infrastructure as Code written in Terraform (`aws/terraform/main.tf`), AWS S3 bucket policies with Origin Access Control (OAC), and deployment scripts in PowerShell (`aws/deploy-aws.ps1`) and Bash (`aws/deploy-aws.sh`).
   - **Netlify:** Complete `netlify.toml` and `_headers` security rules.

3. **Security & Custom Domain:**
   - Enforced TLS 1.3 encryption with automated certificate renewal.
   - Comprehensive security headers: HSTS (`max-age=31536000`), Content Security Policy (CSP), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, and `Referrer-Policy`.
   - Complete custom domain DNS routing instructions for Route 53 and Cloudflare in `docs/SECURITY_AND_SSL.md`.

4. **Synthetic Uptime & Observability:**
   - Synthetic health check endpoint at `/health.json` providing JSON status payload.
   - Multi-location synthetic monitoring configured via UptimeRobot and Better Stack with 60-second intervals and alert channels.
   - Detailed monitoring setup guide in `docs/MONITORING_SETUP.md`.

5. **Project Documentation & Visual Proof:**
   - Comprehensive `README.md` with step-by-step setup guides and platform comparison.
   - Formal project report in `docs/PROJECT_REPORT.md` including cost analysis, architecture breakdown, and performance benchmarks.
   - High-resolution SVG architecture diagrams, UI mockups, and monitoring dashboards in `docs/screenshots/`.

---

### 3. Experience, Review, and Suggestions

#### My Experience:
Working on this project was an enriching experience that bridged frontend web engineering with real-world cloud architecture and DevOps automation. Building the site with pure HTML, CSS, and JavaScript reinforced the value of lean, dependency-free development—resulting in sub-100ms render speeds. Implementing AWS S3 with Origin Access Control (OAC) and CloudFront demonstrated the necessity of zero-trust architecture, ensuring that storage buckets are never exposed to direct public traffic while maintaining global edge availability.

#### Review:
The project tasks were clearly defined, practical, and highly relevant to modern industry standards. Combining website development with cloud hosting, CI/CD automation, custom domain security, and uptime monitoring reflects the full lifecycle of delivering and maintaining production cloud applications.

#### Suggestions:
1. **Multi-Region Failover Workshops:** Including a guided exercise on configuring active-passive DNS failover across two cloud providers (e.g., AWS S3 primary and Cloudflare Pages secondary) would offer even deeper insights into disaster recovery.
2. **Edge Computing Functions:** Adding an optional task to write a CloudFront Function or Lambda@Edge script (e.g., for basic auth, URL rewrites, or geo-based redirections) would showcase advanced edge-compute capabilities.

---

Thank you for the opportunity to work on this project. I look forward to your review and feedback.

Sincerely,  
**Shaik Mohamed**  
GitHub: [@shaikmohamed673-dev](https://github.com/shaikmohamed673-dev)  
Email: shaikmohamed673@gmail.com
