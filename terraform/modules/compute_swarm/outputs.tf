output "manager_instance_id" {
  description = "EC2 Instance ID of the Swarm Manager"
  value       = aws_instance.swarm_manager.id
}

output "manager_private_ip" {
  description = "Private IP of the Swarm Manager node"
  value       = aws_instance.swarm_manager.private_ip
}

output "autoscaling_group_id" {
  description = "ID of the Swarm Worker Auto Scaling Group"
  value       = aws_autoscaling_group.swarm_workers.id
}

output "autoscaling_group_name" {
  description = "Name of the Swarm Worker Auto Scaling Group"
  value       = aws_autoscaling_group.swarm_workers.name
}
