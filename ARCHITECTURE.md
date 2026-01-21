# Module Dependency Graph

This document shows the dependencies between modules and how they interact.

## Module Dependency Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Root Module                              │
│                         (main.tf)                                │
└─────────────────────────────────────────────────────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
                ▼                ▼                ▼
        ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
        │  VPC Module  │  │  IAM Module  │  │   Security   │
        │              │  │              │  │    Module    │
        │ - VPC        │  │ - Roles      │  │ - SG (EC2)   │
        │ - Subnets    │  │ - Profiles   │  │              │
        │ - IGW        │  │              │  │              │
        │ - Routes     │  │              │  │              │
        └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
               │                 │                 │
               │    ┌────────────┴────────────┐    │
               │    │                         │    │
               └────┼─────────────────────────┼────┘
                    │                         │
                    ▼                         ▼
            ┌──────────────┐          ┌──────────────┐
            │   Compute    │          │  RDS Module  │
            │    Module    │          │              │
            │              │          │ - DB Subnet  │
            │ - Launch Tpl │          │ - RDS SG     │
            │ - ASG        │          │ - PostgreSQL │
            └──────┬───────┘          └──────────────┘
                   │
                   │
                   ▼
            ┌──────────────┐
            │  ECS Module  │
            │              │
            │ - Cluster    │
            │ - Capacity   │
            │   Provider   │
            │ - Task Def   │
            │ - Service    │
            └──────────────┘
```

## Module Inputs and Outputs

### VPC Module
**Inputs:**
- `vpc_cidr`
- `public_subnet_cidr`
- `availability_zone`
- `aws_region`

**Outputs:**
- `vpc_id` → Used by Security, RDS
- `public_subnet_id` → Used by Compute, RDS
- `public_subnet_2_id` → Used by RDS
- `internet_gateway_id`
- `route_table_id`

### Security Module
**Inputs:**
- `vpc_id` ← From VPC module
- `allowed_ssh_cidrs`

**Outputs:**
- `instance_security_group_id` → Used by Compute, RDS

### IAM Module
**Inputs:**
- `project_name`

**Outputs:**
- `ecs_instance_profile_name` → Used by Compute
- `ecs_task_execution_role_arn` → Used by ECS

### Compute Module
**Inputs:**
- `subnet_id` ← From VPC module
- `security_group_id` ← From Security module
- `iam_instance_profile_name` ← From IAM module
- `instance_type`
- `key_name`
- `asg_*` settings

**Outputs:**
- `asg_arn` → Used by ECS module
- `asg_name`
- `launch_template_id`

### ECS Module
**Inputs:**
- `asg_arn` ← From Compute module
- `ecs_task_execution_role_arn` ← From IAM module
- `ecs_task_cpu`
- `ecs_task_memory`
- `ecs_container_image`

**Outputs:**
- `ecs_cluster_name`
- `ecs_service_name`
- `ecs_capacity_provider_name`

### RDS Module
**Inputs:**
- `vpc_id` ← From VPC module
- `subnet_ids` ← From VPC module
- `instance_security_group_id` ← From Security module
- `db_*` settings

**Outputs:**
- `rds_endpoint`
- `rds_port`
- `rds_database_name`

## Destruction Order

When running `terraform destroy`, resources are destroyed in this order:

1. **ECS Service** (stops tasks)
2. **ECS Capacity Provider** (disassociates from cluster)
3. **RDS Instance** (database)
4. **Auto Scaling Group** (terminates EC2 instances)
5. **ECS Cluster** (after service is gone)
6. **Security Groups** (after instances are terminated)
7. **IAM Instance Profile** (after instances are gone)
8. **Route Tables** (after instances are gone)
9. **Internet Gateway** (after routes are cleared)
10. **Subnets** (after all resources detached)
11. **VPC** (last)

This order is managed through Terraform's implicit dependency graph based on resource references, ensuring clean teardown without dependency violations.
