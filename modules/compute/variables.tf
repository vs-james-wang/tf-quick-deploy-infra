variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "sre-test"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name tag for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for instances"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for user data"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum size of ASG"
  type        = number
  default     = 0
}

variable "asg_max_size" {
  description = "Maximum size of ASG"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired capacity of ASG"
  type        = number
  default     = 1
}
