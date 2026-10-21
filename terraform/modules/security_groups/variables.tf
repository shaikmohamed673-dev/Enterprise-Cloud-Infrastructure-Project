variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "Allowed CIDR blocks for administrative access (SSH, Prometheus)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Can be restricted to office/VPN CIDR
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
