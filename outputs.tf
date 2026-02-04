output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "ID of the instance security group"
  value       = module.security.instance_security_group_id
}

# ASG Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.compute.launch_template_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.asg_arn
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "ecs_capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = module.ecs.ecs_capacity_provider_name
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "Name of the database"
  value       = module.rds.rds_database_name
}

# Aurora Outputs
output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = module.aurora.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora.cluster_reader_endpoint
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = module.aurora.database_name
}

output "aurora_port" {
  description = "Aurora database port"
  value       = module.aurora.port
}
