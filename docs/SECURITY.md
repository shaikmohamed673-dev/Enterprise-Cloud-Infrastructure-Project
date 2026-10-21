# Security Architecture & Hardening Baseline

## 1. Security Philosophy: Defense in Depth

This infrastructure enforces multi-layered defense to protect sensitive application data, computing assets, and administrative access.

```text
[ Layer 1: Edge / Network ]       ---> AWS VPC, Public/Private Subnets, Strict Security Groups
[ Layer 2: Host Operating System ] ---> Kernel Sysctl Hardening, UFW, Disabling Root SSH, Fail2ban
[ Layer 3: Container Engine ]     ---> Non-Root Users, Read-Only Filesystems, Dropped Capabilities
[ Layer 4: Identity & Secrets ]    ---> IAM Least Privilege, Docker Swarm Encrypted Secrets, KMS S3
```

---

## 2. Network Security & Ingress Control

- **Zero Compute in Public Subnets**: No application EC2 instance has a public IPv4 address. All compute nodes reside in private subnets with RFC 1918 addresses (`10.0.11.0/24`, `10.0.12.0/24`).
- **Encrypted Overlay Networking**: Swarm overlay traffic uses IPsec encryption (`--opt encrypted`) when crossing non-trusted network boundaries.
- **Micro-segmentation**: Microservices are segmented across separate overlay networks:
  - Nginx is isolated from the database tier.
  - The database tier cannot be accessed from public subnets.

---

## 3. Host Hardening (CIS Benchmark Baseline)

Applied via `security/harden-node.sh`:
- **Network Stack Hardening**:
  - `net.ipv4.tcp_syncookies = 1` (Protects against TCP SYN flood attacks).
  - `net.ipv4.conf.all.rp_filter = 1` (Eliminates IP spoofing).
  - `net.ipv4.conf.all.accept_redirects = 0` (Prevents malicious routing cache modification).
- **Address Space Layout Randomization (ASLR)**:
  - `kernel.randomize_va_space = 2` (Mitigates buffer overflow exploits).
- **SSH Hardening**:
  - Root login disabled (`PermitRootLogin no`).
  - Password authentication disabled (`PasswordAuthentication no`).
  - Max authentication tries capped at 3 (`MaxAuthTries 3`).
  - Inactive session timeout enforced (`ClientAliveInterval 300`).
- **Elimination of Open SSH Ports**:
  - Compute instances use AWS Systems Manager (SSM) Session Manager. Management access is authenticated via IAM and encrypted via TLS, allowing port 22 to remain completely closed.

---

## 4. Container Security & Image Hardening

- **Non-Root Execution**: Container processes run under dedicated non-root UID/GID `10001:10001` defined in `app/Dockerfile`.
- **Privilege Restriction**: Docker daemon is configured with `"no-new-privileges": true` in `security/docker-daemon.json`, preventing privilege escalation via setuid/setgid binaries.
- **Inter-Container Communication (ICC)**: Default bridge ICC is disabled (`"icc": false`).
- **Continuous CVE Scanning**: GitHub Actions pipeline runs **Trivy** vulnerability audits on every build, blocking images containing unpatched Critical CVEs.

---

## 5. Secret Management & Encryption at Rest

- **Docker Secrets**: Database passwords and credentials are never stored in environment variables or Git commits. They are injected at runtime into tmpfs memory mounts at `/run/secrets/`.
- **S3 Bucket Encryption**: All database backups and disaster recovery archives are encrypted at rest using AWS KMS or AES-256 Server-Side Encryption (`aws:kms` or `AES256`).
- **Enforced Transport Encryption**: S3 bucket policy enforces `aws:SecureTransport: true`, denying any non-HTTPS requests.
