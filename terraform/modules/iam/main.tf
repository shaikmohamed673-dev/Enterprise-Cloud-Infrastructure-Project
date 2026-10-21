# ==============================================================================
# IAM Least-Privilege Execution Roles & Profiles
# ==============================================================================

resource "aws_iam_role" "swarm_node_role" {
  name = "${var.project_name}-${var.environment}-swarm-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-swarm-node-role"
      Environment = var.environment
    }
  )
}

# Attach AWS SSM for secure console access without open SSH
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.swarm_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch Agent policy for OS and system metrics
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.swarm_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 Backup Bucket Access Policy (Least Privilege)
resource "aws_iam_policy" "s3_backup_access" {
  name        = "${var.project_name}-${var.environment}-s3-backup-policy"
  description = "Grants Swarm managers permission to archive backups to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAndReadBackupBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.backup_bucket_arn != "*" ? var.backup_bucket_arn : "arn:aws:s3:::*"
      },
      {
        Sid    = "PutAndGetBackupObjects"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = var.backup_bucket_arn != "*" ? "${var.backup_bucket_arn}/*" : "arn:aws:s3:::*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_backup" {
  role       = aws_iam_role.swarm_node_role.name
  policy_arn = aws_iam_policy.s3_backup_access.arn
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "swarm_node_profile" {
  name = "${var.project_name}-${var.environment}-swarm-node-profile"
  role = aws_iam_role.swarm_node_role.name

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-swarm-node-profile"
      Environment = var.environment
    }
  )
}
