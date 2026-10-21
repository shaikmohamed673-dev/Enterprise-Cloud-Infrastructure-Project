# ==============================================================================
# Compute Module: Docker Swarm Manager & Auto-Scaling Worker Cluster
# ==============================================================================

# Query Ubuntu 22.04 LTS official AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# 1. Docker Swarm Manager Node (Primary Control Plane)
# ------------------------------------------------------------------------------
resource "aws_instance" "swarm_manager" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.manager_security_group_id]
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = file("${path.module}/scripts/manager_bootstrap.sh")

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-swarm-manager"
      Role        = "swarm-manager"
      Environment = var.environment
    }
  )
}

# Attach Manager Node to Application Load Balancer Target Group
resource "aws_lb_target_group_attachment" "manager_tg_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.swarm_manager.id
  port             = 80
}

# ------------------------------------------------------------------------------
# 2. Docker Swarm Worker Launch Template
# ------------------------------------------------------------------------------
resource "aws_launch_template" "swarm_worker" {
  name_prefix   = "${var.project_name}-${var.environment}-worker-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.worker_security_group_id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/scripts/worker_bootstrap.sh", {
    manager_ip = aws_instance.swarm_manager.private_ip
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name        = "${var.project_name}-${var.environment}-swarm-worker"
        Role        = "swarm-worker"
        Environment = var.environment
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 3. Docker Swarm Worker Auto Scaling Group (ASG)
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "swarm_workers" {
  name_prefix         = "${var.project_name}-${var.environment}-workers-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  min_size     = var.min_workers
  max_size     = var.max_workers
  desired_capacity = var.desired_workers

  launch_template {
    id      = aws_launch_template.swarm_worker.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# ------------------------------------------------------------------------------
# 4. Target Tracking Auto-Scaling Policy (CPU 70%)
# ------------------------------------------------------------------------------
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-${var.environment}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.swarm_workers.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
