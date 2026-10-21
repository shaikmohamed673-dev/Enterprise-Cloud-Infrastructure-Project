variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "enterprise-cloud"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for production VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for Swarm nodes"
  type        = string
  default     = "t3.medium"
}

variable "min_workers" {
  description = "Minimum worker nodes"
  type        = number
  default     = 2
}

variable "max_workers" {
  description = "Maximum worker nodes"
  type        = number
  default     = 6
}

variable "desired_workers" {
  description = "Desired worker nodes"
  type        = number
  default     = 3
}

variable "admin_cidr_blocks" {
  description = "Admin IP blocks for management ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
