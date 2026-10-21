provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 1. VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = false # High Availability across multiple AZs
}

# 2. Security Groups Module
module "security_groups" {
  source = "../../modules/security_groups"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  admin_cidr_blocks = var.admin_cidr_blocks
}

# 3. S3 Backups & Disaster Recovery Storage Module
module "s3_backups" {
  source = "../../modules/s3_backups"

  project_name = var.project_name
  environment  = var.environment
}

# 4. IAM Roles & Profiles Module
module "iam" {
  source = "../../modules/iam"

  project_name      = var.project_name
  environment       = var.environment
  backup_bucket_arn = module.s3_backups.bucket_arn
}

# 5. Application Load Balancer Module
module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  target_port       = 80
  health_check_path = "/health"
}

# 6. Docker Swarm Compute Cluster Module
module "compute_swarm" {
  source = "../../modules/compute_swarm"

  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.instance_type
  private_subnet_ids        = module.vpc.private_subnet_ids
  manager_security_group_id = module.security_groups.swarm_manager_security_group_id
  worker_security_group_id  = module.security_groups.swarm_worker_security_group_id
  iam_instance_profile      = module.iam.instance_profile_name
  target_group_arn          = module.alb.target_group_arn
  min_workers               = var.min_workers
  max_workers               = var.max_workers
  desired_workers           = var.desired_workers
}
