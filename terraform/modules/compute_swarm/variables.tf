variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for manager and worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "private_subnet_ids" {
  description = "Subnet IDs for Swarm nodes (Private Subnets for enterprise security)"
  type        = list(string)
}

variable "manager_security_group_id" {
  description = "Security Group ID for the Manager node"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security Group ID for the Worker nodes"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2 nodes"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN of the ALB"
  type        = string
}

variable "min_workers" {
  description = "Minimum number of worker instances in ASG"
  type        = number
  default     = 2
}

variable "max_workers" {
  description = "Maximum number of worker instances in ASG"
  type        = number
  default     = 5
}

variable "desired_workers" {
  description = "Desired number of worker instances in ASG"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Optional SSH key name (leave blank if relying purely on AWS SSM Session Manager)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
