output "ecs_instance_role_arn" {
  description = "ARN of the ECS instance IAM role"
  value       = aws_iam_role.ecs_instance.arn
}

output "ecs_instance_role_name" {
  description = "Name of the ECS instance IAM role"
  value       = aws_iam_role.ecs_instance.name
}

output "ecs_instance_profile_name" {
  description = "Name of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.name
}
