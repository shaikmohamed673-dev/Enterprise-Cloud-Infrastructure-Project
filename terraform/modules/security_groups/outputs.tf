output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "swarm_manager_security_group_id" {
  description = "ID of the Swarm Manager security group"
  value       = aws_security_group.swarm_manager.id
}

output "swarm_worker_security_group_id" {
  description = "ID of the Swarm Worker security group"
  value       = aws_security_group.swarm_worker.id
}

output "bastion_security_group_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

output "monitoring_security_group_id" {
  description = "ID of the Monitoring security group"
  value       = aws_security_group.monitoring.id
}
