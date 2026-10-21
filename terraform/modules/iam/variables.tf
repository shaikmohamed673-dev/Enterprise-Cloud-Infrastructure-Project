variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "backup_bucket_arn" {
  description = "ARN of the S3 backup bucket for automated backups"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
