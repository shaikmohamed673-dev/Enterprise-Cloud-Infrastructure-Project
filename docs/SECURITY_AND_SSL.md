# Custom Domain, SSL/TLS, and Security Hardening Guide

This document details the security architecture, certificate lifecycle, custom domain routing, and HTTP header protections implemented for the Cloud-Based Static Website.

---

## 1. Custom Domain DNS Configuration

To map a custom domain (e.g. `cloudpulse.example.com` or `example.com`) to the cloud infrastructure:

### A. AWS Route 53 (Apex and Subdomain)
1. **Apex Domain (`example.com`)**:
   - Record Type: `A - IPv4 address`
   - Alias: `Yes`
   - Route Traffic To: `Alias to CloudFront distribution`
   - Target: `d111111abcdef8.cloudfront.net`
2. **Subdomain (`www.example.com`)**:
   - Record Type: `CNAME`
   - Value: `d111111abcdef8.cloudfront.net`

### B. GitHub Pages Custom Domain
1. In the GitHub repository settings (`Settings > Pages > Custom domain`), enter your domain name: `example.com`.
2. Configure DNS records at your domain registrar:
   - **Apex A Records**:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`
   - **Subdomain CNAME Record**:
     - Host: `www` -> Value: `<username>.github.io`
3. Check the **Enforce HTTPS** box once DNS propagates.

---

## 2. SSL/TLS Encryption Architecture

### A. AWS Certificate Manager (ACM)
- When using CloudFront, the ACM SSL certificate **must** be requested in the `us-east-1` (N. Virginia) region.
- Validation is completed via DNS TXT/CNAME records.
- Renewal is 100% automated by AWS at 60 days before expiration.
- Minimum protocol version enforced: `TLSv1.2_2021` or `TLSv1.3`.

### B. Automated TLS on GitHub Pages / Netlify
- Both platforms provision free Let's Encrypt certificates with automated 90-day renewals.
- Automatic HTTP to HTTPS redirection (301 Permanent Redirect).

---

## 3. HTTP Security Headers Matrix

The website deploys the following enterprise-grade HTTP response headers via `_headers` and `netlify.toml`:

| Security Header | Directive | Security Impact |
|:---|:---|:---|
| **Strict-Transport-Security (HSTS)** | `max-age=31536000; includeSubDomains; preload` | Forces browsers to strictly communicate over HTTPS for at least 1 year, preventing SSL stripping attacks. |
| **X-Frame-Options** | `DENY` | Prevents the website from being loaded in an `<iframe>`, eliminating clickjacking vulnerabilities. |
| **X-Content-Type-Options** | `nosniff` | Disables MIME type sniffing, preventing browsers from interpreting malicious files as executable code. |
| **Referrer-Policy** | `strict-origin-when-cross-origin` | Protects privacy by omitting sensitive URL query strings when navigating across origins. |
| **Permissions-Policy** | `camera=(), microphone=(), geolocation=()` | Blocks browser hardware access from third-party scripts. |
| **Content-Security-Policy (CSP)** | `default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; ...` | Prevents Cross-Site Scripting (XSS) and data injection attacks by restricting allowed origins. |

---

## 4. AWS S3 Origin Access Control (OAC) Hardening

Unlike legacy public buckets, this deployment keeps the S3 bucket private:
1. **S3 Public Access Block**: All four flags set to `true`.
2. **Access Policy**: The S3 bucket policy explicitly allows only `cloudfront.amazonaws.com` service principal with condition `StringEquals: { "AWS:SourceArn": "arn:aws:cloudfront::..." }`.
3. **Protection**: Direct S3 endpoint calls return `403 Forbidden`. Only traffic traversing the CloudFront CDN with TLS and WAF inspection is served.
