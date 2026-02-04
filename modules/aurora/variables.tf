variable "project_name" {
  description = "Project name for resource naming"
  type        = string
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

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Aurora engine type (aurora-postgresql or aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "15.8"
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port (5432 for PostgreSQL, 3306 for MySQL)"
  type        = number
  default     = 5432
}

variable "serverless_min_capacity" {
  description = "Minimum ACU for Serverless v2 (0.5 is minimum)"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Maximum ACU for Serverless v2"
  type        = number
  default     = 1
}

variable "publicly_accessible" {
  description = "Whether the Aurora instance is publicly accessible"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
