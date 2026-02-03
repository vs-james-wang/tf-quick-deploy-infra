# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  aws_region         = var.aws_region
  project_name       = "sre-test"
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  project_name      = "sre-test"
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = "sre-test"
}

# ECS Module (must be created before compute to get cluster name)
module "ecs" {
  source = "./modules/ecs"

  project_name                = "sre-test"
  asg_arn                     = module.compute.asg_arn
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory
  ecs_container_image         = var.ecs_container_image
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name              = "sre-test"
  instance_type             = var.instance_type
  instance_name             = var.instance_name
  key_name                  = var.key_name
  subnet_id                 = module.vpc.public_subnet_id
  security_group_id         = module.security.instance_security_group_id
  iam_instance_profile_name = module.iam.ecs_instance_profile_name
  ecs_cluster_name          = "sre-test-cluster"
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  asg_desired_capacity      = var.asg_desired_capacity
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name               = "sre-test"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = [module.vpc.public_subnet_id, module.vpc.public_subnet_2_id]
  instance_security_group_id = module.security.instance_security_group_id
  allowed_ssh_cidrs          = var.allowed_ssh_cidrs
  db_instance_class          = var.db_instance_class
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
}


