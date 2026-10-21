output "bucket_id" {
  description = "The name/ID of the S3 backup bucket"
  value       = aws_s3_bucket.backups.id
}

output "bucket_arn" {
  description = "The ARN of the S3 backup bucket"
  value       = aws_s3_bucket.backups.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.backups.bucket_domain_name
}
