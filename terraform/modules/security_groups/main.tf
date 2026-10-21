# ==============================================================================
# Security Groups: Enterprise Defense-in-Depth Layering
# ==============================================================================

# 1. Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Controls public web ingress to the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP inbound from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS inbound from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ALB outbound to backend compute nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-alb-sg"
      Environment = var.environment
    }
  )
}

# 2. Bastion Jump Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Controls secure administrative SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Restricted SSH access from admin IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  egress {
    description = "Outbound to private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-bastion-sg"
      Environment = var.environment
    }
  )
}

# 3. Docker Swarm Manager Security Group
resource "aws_security_group" "swarm_manager" {
  name        = "${var.project_name}-${var.environment}-swarm-manager-sg"
  description = "Controls traffic for Docker Swarm Manager nodes"
  vpc_id      = var.vpc_id

  # Ingress from ALB
  ingress {
    description     = "HTTP traffic routed from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Reverse proxy / app port from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from Bastion Host
  ingress {
    description     = "SSH access via Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Docker Swarm Cluster Internal Communications (Self & Worker SG)
  ingress {
    description = "Docker Swarm cluster management (Raft consensus)"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Docker node discovery and control communication TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Docker node discovery and control communication UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Docker overlay network traffic (VXLAN data plane)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-swarm-manager-sg"
      Environment = var.environment
    }
  )
}

# 4. Docker Swarm Worker Security Group
resource "aws_security_group" "swarm_worker" {
  name        = "${var.project_name}-${var.environment}-swarm-worker-sg"
  description = "Controls traffic for Docker Swarm Worker nodes"
  vpc_id      = var.vpc_id

  # Ingress from ALB
  ingress {
    description     = "HTTP traffic routed from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Reverse proxy / API traffic routed from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from Bastion Host
  ingress {
    description     = "SSH access via Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Inter-node communications between Managers and Workers
  ingress {
    description     = "Docker node discovery TCP from Manager"
    from_port       = 7946
    to_port         = 7946
    protocol        = "tcp"
    security_groups = [aws_security_group.swarm_manager.id]
    self            = true
  }

  ingress {
    description     = "Docker node discovery UDP from Manager"
    from_port       = 7946
    to_port         = 7946
    protocol        = "udp"
    security_groups = [aws_security_group.swarm_manager.id]
    self            = true
  }

  ingress {
    description     = "Docker overlay network VXLAN UDP"
    from_port       = 4789
    to_port         = 4789
    protocol        = "udp"
    security_groups = [aws_security_group.swarm_manager.id]
    self            = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-swarm-worker-sg"
      Environment = var.environment
    }
  )
}

# Additional cross-references: Allow Workers to talk to Manager Raft & Gossip
resource "aws_security_group_rule" "manager_from_workers_raft" {
  type                     = "ingress"
  from_port                = 2377
  to_port                  = 2377
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.swarm_worker.id
  security_group_id        = aws_security_group.swarm_manager.id
  description              = "Allow workers to join manager cluster on port 2377"
}

resource "aws_security_group_rule" "manager_from_workers_gossip_tcp" {
  type                     = "ingress"
  from_port                = 7946
  to_port                  = 7946
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.swarm_worker.id
  security_group_id        = aws_security_group.swarm_manager.id
  description              = "Allow gossip TCP from workers to manager"
}

resource "aws_security_group_rule" "manager_from_workers_gossip_udp" {
  type                     = "ingress"
  from_port                = 7946
  to_port                  = 7946
  protocol                 = "udp"
  source_security_group_id = aws_security_group.swarm_worker.id
  security_group_id        = aws_security_group.swarm_manager.id
  description              = "Allow gossip UDP from workers to manager"
}

resource "aws_security_group_rule" "manager_from_workers_vxlan" {
  type                     = "ingress"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  source_security_group_id = aws_security_group.swarm_worker.id
  security_group_id        = aws_security_group.swarm_manager.id
  description              = "Allow overlay VXLAN UDP from workers to manager"
}

# 5. Monitoring Security Group (Prometheus & Grafana)
resource "aws_security_group" "monitoring" {
  name        = "${var.project_name}-${var.environment}-monitoring-sg"
  description = "Controls access to Grafana and Prometheus monitoring stack"
  vpc_id      = var.vpc_id

  ingress {
    description = "Grafana Dashboard UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  ingress {
    description = "Prometheus Server UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  egress {
    description = "Metrics scraping outbound to all compute nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-monitoring-sg"
      Environment = var.environment
    }
  )
}

# Allow Prometheus to scrape Node Exporter (9100) and cAdvisor (8080/8081) on Managers & Workers
resource "aws_security_group_rule" "manager_scrape_node_exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
  security_group_id        = aws_security_group.swarm_manager.id
  description              = "Prometheus scraper for Node Exporter"
}

resource "aws_security_group_rule" "worker_scrape_node_exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
  security_group_id        = aws_security_group.swarm_worker.id
  description              = "Prometheus scraper for Node Exporter"
}
