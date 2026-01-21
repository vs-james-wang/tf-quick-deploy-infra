variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "sre-test"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}
