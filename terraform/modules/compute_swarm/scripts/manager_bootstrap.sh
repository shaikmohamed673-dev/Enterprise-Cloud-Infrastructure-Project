#!/bin/bash
set -euxo pipefail

# ==============================================================================
# Docker Swarm Manager Node Automated Bootstrapper
# ==============================================================================

echo "=== [1/6] Updating packages and installing prerequisites ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    awscli \
    htop \
    ufw

echo "=== [2/6] Installing official Docker CE ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "=== [3/6] Hardening Docker Daemon ==="
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

echo "=== [4/6] Initializing Docker Swarm Manager ==="
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || hostname -I | awk '{print $1}')
docker swarm init --advertise-addr "${PRIVATE_IP}"

echo "=== [5/6] Creating Production Overlay Networks ==="
docker network create --driver overlay --attachable frontend-net
docker network create --driver overlay --attachable backend-net
docker network create --driver overlay --attachable monitoring-net

echo "=== [6/6] Storing Worker Join Token in AWS SSM Parameter Store ==="
WORKER_TOKEN=$(docker swarm join-token worker -q)
MANAGER_TOKEN=$(docker swarm join-token manager -q)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region || echo "us-east-1")

aws ssm put-parameter \
    --name "/enterprise-cloud/swarm/worker-token" \
    --type "SecureString" \
    --value "${WORKER_TOKEN}" \
    --overwrite \
    --region "${REGION}" || echo "Warning: Could not save to SSM, stored locally at /etc/swarm-worker-token"

echo "${WORKER_TOKEN}" > /etc/swarm-worker-token
echo "${PRIVATE_IP}" > /etc/swarm-manager-ip

echo "=== Swarm Manager Bootstrap Completed Successfully ==="
