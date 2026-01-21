variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "sre-test"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "instance_security_group_id" {
  description = "Security group ID of EC2 instances for DB access"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
