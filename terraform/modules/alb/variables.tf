variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where target groups are created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "target_port" {
  description = "Backend port on the Swarm cluster where traffic will be routed"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP health check endpoint path"
  type        = string
  default     = "/health"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
