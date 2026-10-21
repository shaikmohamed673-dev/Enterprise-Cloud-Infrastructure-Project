output "instance_profile_name" {
  description = "Name of the IAM instance profile for Swarm EC2 nodes"
  value       = aws_iam_instance_profile.swarm_node_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile for Swarm EC2 nodes"
  value       = aws_iam_instance_profile.swarm_node_profile.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.swarm_node_role.name
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.swarm_node_role.arn
}
