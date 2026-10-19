variable "aws_region" {
  type        = string
  description = "AWS region for primary resources"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket (must be globally unique)"
  default     = "cognevance-static-website"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "production"
}
