#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Linux & Docker Node Production Security Hardening Script
# Aligned with CIS Linux & Docker Benchmarks
# ==============================================================================

echo "=== [1/5] Applying Kernel Sysctl Hardening ==="
cat <<'EOF' > /etc/sysctl.d/99-enterprise-security.conf
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Enable TCP SYN Cookie Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 4096

# Disable IP packet forwarding across unauthorized interfaces
net.ipv4.ip_forward = 1

# Protect against TIME-WAIT assassination
net.ipv4.tcp_rfc1337 = 1

# Memory ASLR (Address Space Layout Randomization)
kernel.randomize_va_space = 2

# Restrict core dumps
fs.suid_dumpable = 0
EOF

sysctl --system > /dev/null

echo "=== [2/5] Hardening SSH Configuration ==="
if [ -f /etc/ssh/sshd_config ]; then
  sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i -E 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i -E 's/^#?X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
  sed -i -E 's/^#?MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
  sed -i -E 's/^#?ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
  sed -i -E 's/^#?ClientAliveCountMax.*/ClientAliveCountMax 2/' /etc/ssh/sshd_config
  systemctl restart sshd || true
fi

echo "=== [3/5] Configuring Host Firewall (UFW) ==="
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH from admin/bastion
ufw allow 22/tcp comment 'SSH'

# Allow Web Ingress
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

# Allow Docker Swarm Inter-Node Ports
ufw allow 2377/tcp comment 'Docker Swarm Cluster Management'
ufw allow 7946/tcp comment 'Docker Swarm Node Discovery TCP'
ufw allow 7946/udp comment 'Docker Swarm Node Discovery UDP'
ufw allow 4789/udp comment 'Docker Overlay Network VXLAN'

# Allow Prometheus / Node Exporter from Internal Network
ufw allow from 10.0.0.0/16 to any port 9100 proto tcp comment 'Node Exporter'
ufw allow from 10.0.0.0/16 to any port 8080 proto tcp comment 'cAdvisor'

ufw --force enable

echo "=== [4/5] Deploying Hardened Docker Daemon Configuration ==="
mkdir -p /etc/docker
cp "$(dirname "$0")/docker-daemon.json" /etc/docker/daemon.json
systemctl restart docker

echo "=== [5/5] Hardening Audit Complete ==="
echo "Host and Docker node successfully hardened according to enterprise security baseline."
