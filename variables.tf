variable "project_name" {
  description = "Project name used for resource naming across all modules"
  type        = string
  default     = "sre-test"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-west-2a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "sre-test-instance"
}

variable "standalone_instance_type" {
  description = "Instance type for standalone EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (leave empty to use latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

# ASG Variables
variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}

# ECS Variables
variable "ecs_container_image" {
  description = "Container image for ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_container_port" {
  description = "Container port for ECS task"
  type        = number
  default     = 80
}

# Compute Variables
variable "ebs_volume_size" {
  description = "EBS volume size in GB for EC2 instances"
  type        = number
  default     = 50
}

# RDS Variables
variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "testdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  default     = "LabPassword123!"  # Default for lab/testing only - change in production
}

# Aurora Variables
variable "aurora_engine" {
  description = "Aurora engine type (aurora-postgresql or aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "15.8"
}

variable "aurora_database_name" {
  description = "Name of the default Aurora database"
  type        = string
  default     = "appdb"
}

variable "aurora_master_username" {
  description = "Master username for Aurora"
  type        = string
  default     = "postgres"
}

variable "aurora_master_password" {
  description = "Master password for Aurora"
  type        = string
  sensitive   = true
  default     = null
}

variable "aurora_min_capacity" {
  description = "Minimum ACU for Aurora Serverless v2 (0.5 is minimum)"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Maximum ACU for Aurora Serverless v2"
  type        = number
  default     = 1
}

variable "aurora_publicly_accessible" {
  description = "Whether the Aurora instance is publicly accessible"
  type        = bool
  default     = true
}
