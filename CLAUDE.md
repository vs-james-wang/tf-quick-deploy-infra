# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Modular Terraform infrastructure for spinning up ECS on EC2 with RDS PostgreSQL. Designed for SRE testing and rapid infrastructure provisioning.

**Tech Stack**: Terraform >= 1.0, AWS Provider ~> 5.0, S3 Remote Backend

## Common Commands

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply (recommended order for clean dependency resolution)
terraform apply -target=module.vpc -target=module.security -target=module.iam
terraform apply -target=module.compute
terraform apply -target=module.ecs
terraform apply -target=module.rds
terraform apply -target=module.aurora

# Destroy (MUST follow this order to avoid stuck resources)
terraform destroy -target=module.aurora
terraform destroy -target=module.ecs
terraform destroy -target=module.compute
terraform destroy

# Detailed ECS destroy sequence (if issues occur)
terraform destroy -target=module.ecs.aws_ecs_service.main
terraform destroy -target=module.ecs.aws_ecs_cluster_capacity_providers.main
terraform destroy -target=module.ecs.aws_ecs_capacity_provider.main
terraform destroy -target=module.ecs.aws_ecs_cluster.main
terraform destroy -target=module.compute
terraform destroy

# Generate dependency graph
terraform graph | dot -Tsvg > graph.svg
```

## Architecture

```
Root Module (main.tf)
├── modules/vpc/       # VPC, subnets, IGW, route tables
├── modules/security/  # EC2 security group
├── modules/iam/       # IAM roles, instance profiles
├── modules/compute/   # Launch template, Auto Scaling Group
├── modules/ecs/       # ECS cluster, capacity provider, service, task definition
├── modules/rds/       # RDS PostgreSQL, DB subnet group, security group
└── modules/aurora/    # Aurora Serverless v2 cluster (PostgreSQL/MySQL)
```

### Module Dependencies

- **vpc**: Independent, creates networking foundation
- **security**: Depends on vpc (via vpc_id)
- **iam**: Independent, creates roles/profiles
- **compute**: Depends on vpc, security, iam
- **ecs**: Depends on compute (explicit), iam; has `depends_on = [module.compute]` in root
- **rds**: Depends on vpc, security
- **aurora**: Depends on vpc, security; uses Serverless v2 with min 0.5 ACU

### Key Design Patterns

- Implicit dependencies preferred over explicit `depends_on`
- Dynamic ingress rules using `dynamic` blocks based on `allowed_ssh_cidrs` list
- `cidrsubnet()` for auto-calculating second subnet CIDR
- `force_delete = true` on ASG for clean teardowns
- Separate `aws_route` resource to avoid circular dependencies with IGW

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize:

```bash
# Required settings
key_name = "your-key-pair"
allowed_ssh_cidrs = ["your.ip.address/32"]

# Sensitive - prefer environment variable
export TF_VAR_db_password="your-secure-password"
```

## State Backend

- **Bucket**: `sre-spin-up-test-resources`
- **Region**: `us-west-2`
- **Encryption**: Enabled

## Operational Notes

- ECS capacity providers hold references to ASG, causing destroy hangs if not destroyed in order
- RDS has `skip_final_snapshot = true` (suitable for testing only)
- Aurora uses Serverless v2 with 0.5-1 ACU default (minimum cost for lab/testing)
- Aurora password falls back to `db_password` if `aurora_master_password` not set
- ASG uses `$Latest` launch template version
- Resources tagged with `lights-out:managed = "true"` for scheduling integration
