#!/bin/bash
set -euxo pipefail

# ==============================================================================
# Docker Swarm Worker Node Automated Bootstrapper
# ==============================================================================

MANAGER_PRIVATE_IP="${manager_ip}"

echo "=== [1/5] Updating packages and installing prerequisites ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    awscli \
    htop

echo "=== [2/5] Installing official Docker CE ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "=== [3/5] Configuring Docker Daemon ==="
mkdir -p /etc/docker
cat <<'EOF' > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "5"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
EOF
systemctl restart docker

echo "=== [4/5] Retrieving Swarm Join Token ==="
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || hostname -I | awk '{print $1}')

# Poll SSM for worker token (up to 5 minutes)
TOKEN=""
for i in $(seq 1 30); do
  TOKEN=$(aws ssm get-parameter --name "/enterprise-cloud/swarm/worker-token" --with-decryption --region "$REGION" --query "Parameter.Value" --output text 2>/dev/null || echo "")
  if [ -n "$TOKEN" ]; then
    break
  fi
  echo "Waiting for manager to register worker token in SSM... ($i/30)"
  sleep 10
done

echo "=== [5/5] Joining Docker Swarm as Worker Node ==="
if [ -n "$TOKEN" ] && [ -n "$MANAGER_PRIVATE_IP" ]; then
  docker swarm join --token "$TOKEN" "$MANAGER_PRIVATE_IP:2377" --advertise-addr "$PRIVATE_IP"
  echo "=== Successfully joined Docker Swarm cluster ==="
else
  echo "Warning: Token or Manager IP was unavailable during bootstrap. Manual join required."
fi
