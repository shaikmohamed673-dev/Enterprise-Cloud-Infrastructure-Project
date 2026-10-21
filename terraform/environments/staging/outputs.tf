output "vpc_id" {
  description = "Staging VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Public URL / DNS of Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "swarm_manager_private_ip" {
  description = "Private IP of the Swarm Manager Node"
  value       = module.compute_swarm.manager_private_ip
}

output "swarm_workers_asg_name" {
  description = "Auto Scaling Group Name for Swarm Workers"
  value       = module.compute_swarm.autoscaling_group_name
}

output "backup_bucket_id" {
  description = "S3 Disaster Recovery Backup Bucket"
  value       = module.s3_backups.bucket_id
}
