variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "sre-test"
}

variable "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  type        = string
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for ECS task"
  type        = number
}

variable "ecs_container_image" {
  description = "Container image for ECS task"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}
