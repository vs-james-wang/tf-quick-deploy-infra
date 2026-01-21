# Dependency Management Strategy

## Overview
This document explains how resource dependencies are managed in the modular Terraform structure to ensure safe creation and destruction of infrastructure.

## Key Principle: Implicit vs Explicit Dependencies

### Implicit Dependencies (Preferred)
Terraform automatically creates a dependency graph based on resource references. When resource A references an attribute from resource B, Terraform knows that B must be created before A and destroyed after A.

**Example:**
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id  # ← Implicit dependency on VPC
}
```

Terraform will:
- **Create**: VPC first, then subnet
- **Destroy**: Subnet first, then VPC

### Explicit Dependencies (When Needed)
Use `depends_on` only when there's a dependency that Terraform cannot infer from resource references.

## Dependency Analysis by Module

### ✅ VPC Module
**Resources**: VPC, IGW, Subnets, Route Tables

**Dependencies**:
- ✅ **IGW → VPC**: Implicit (via `vpc_id`)
- ✅ **Subnets → VPC**: Implicit (via `vpc_id`)
- ✅ **Route Table → VPC**: Implicit (via `vpc_id`)
- ✅ **Route Table → IGW**: Implicit (route references `gateway_id`)
- ✅ **Route Table Associations → Subnet + Route Table**: Implicit

**Destruction Order**: Route Table Associations → Route Table → Subnets → IGW → VPC

**Explicit Dependencies**: ❌ None needed - all handled implicitly

---

### ✅ Security Module
**Resources**: Security Group for EC2 instances

**Dependencies**:
- ✅ **Security Group → VPC**: Implicit (via `vpc_id` from module.vpc.vpc_id)

**Destruction Order**: Security Group destroyed before VPC (implicit)

**Explicit Dependencies**: ❌ None needed

---

### ✅ IAM Module
**Resources**: IAM Roles, Instance Profile

**Dependencies**:
- ✅ **Instance Profile → IAM Role**: Implicit (via `role` reference)
- ✅ **Policy Attachment → IAM Role**: Implicit (via `role` reference)

**Destruction Order**: Instance Profile → Policy Attachments → IAM Roles

**Explicit Dependencies**: ❌ None needed

**Note**: Cannot add `depends_on = [module.compute]` because it would create circular dependency (compute depends on IAM outputs).

---

### ✅ Compute Module
**Resources**: Launch Template, Auto Scaling Group

**Dependencies**:
- ✅ **Launch Template → Security Group**: Implicit (via `security_groups`)
- ✅ **Launch Template → IAM Instance Profile**: Implicit (via `iam_instance_profile.name`)
- ✅ **ASG → Launch Template**: Implicit (via `launch_template.id`)
- ✅ **ASG → Subnet**: Implicit (via `vpc_zone_identifier`)

**Destruction Order**: ASG → Launch Template

**Explicit Dependencies**: ❌ None needed

---

### ✅ ECS Module
**Resources**: Cluster, Capacity Provider, Task Definition, Service

**Dependencies**:
- ✅ **Capacity Provider → ASG**: Implicit (via `auto_scaling_group_arn` from module.compute)
- ✅ **Cluster Capacity Providers → Cluster**: Implicit (via `cluster_name`)
- ✅ **Cluster Capacity Providers → Capacity Provider**: Implicit (via `capacity_providers`)
- ✅ **Service → Cluster**: Implicit (via `cluster`)
- ✅ **Service → Task Definition**: Implicit (via `task_definition`)
- ✅ **Service → Capacity Provider**: Implicit (via `capacity_provider_strategy`)
- ✅ **Service → Cluster Capacity Providers**: **EXPLICIT** (via `depends_on`)
- ✅ **Task Definition → IAM Role**: Implicit (via `execution_role_arn`)

**Destruction Order**: Service → Cluster Capacity Providers → Capacity Provider → Task Definition → Cluster

**Explicit Dependencies**: 
- ✅ `aws_ecs_service.main` depends_on `aws_ecs_cluster_capacity_providers.main`
- ✅ `module.ecs` depends_on `module.compute` (in root main.tf)

---

### ✅ RDS Module
**Resources**: DB Subnet Group, RDS Security Group, RDS Instance

**Dependencies**:
- ✅ **DB Subnet Group → Subnets**: Implicit (via `subnet_ids` from module.vpc)
- ✅ **RDS Security Group → VPC**: Implicit (via `vpc_id`)
- ✅ **RDS Security Group → EC2 Security Group**: Implicit (via `security_groups` reference)
- ✅ **RDS Instance → DB Subnet Group**: Implicit (via `db_subnet_group_name`)
- ✅ **RDS Instance → RDS Security Group**: Implicit (via `vpc_security_group_ids`)

**Destruction Order**: RDS Instance → DB Subnet Group + RDS Security Group

**Explicit Dependencies**: ❌ None needed

---

## Module-Level Dependencies (Root main.tf)

### Current Dependencies

```hcl
module "vpc" { }                    # No dependencies
module "security" {                 # Depends on: module.vpc (implicit via vpc_id)
  vpc_id = module.vpc.vpc_id
}
module "iam" { }                    # No dependencies
module "compute" {                  # Depends on: vpc, security, iam (all implicit)
  subnet_id = module.vpc.public_subnet_id
  security_group_id = module.security.instance_security_group_id
  iam_instance_profile_name = module.iam.ecs_instance_profile_name
}
module "ecs" {                      # Depends on: compute, iam (implicit + explicit)
  asg_arn = module.compute.asg_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  depends_on = [module.compute]     # EXPLICIT
}
module "rds" {                      # Depends on: vpc, security (all implicit)
  vpc_id = module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnet_id, module.vpc.public_subnet_2_id]
  instance_security_group_id = module.security.instance_security_group_id
}
```

### Destruction Order (Terraform will follow this automatically)

1. **ECS Service** (depends on cluster, capacity provider, task def)
2. **ECS Cluster Capacity Providers** (depends on cluster, capacity provider)
3. **ECS Capacity Provider** (depends on ASG)
4. **RDS Instance** (depends on DB subnet group, security group)
5. **Auto Scaling Group** (depends on launch template, subnet)
6. **ECS Task Definition** (depends on IAM role)
7. **ECS Cluster** (after service is gone)
8. **Launch Template** (depends on security group, IAM profile)
9. **DB Subnet Group** (depends on subnets)
10. **RDS Security Group** (depends on VPC)
11. **EC2 Security Group** (depends on VPC)
12. **IAM Instance Profile** (depends on IAM role)
13. **IAM Policy Attachments** (depends on IAM role)
14. **IAM Roles**
15. **Route Table Associations** (depends on route table, subnet)
16. **Route Table** (depends on VPC, IGW)
17. **Subnets** (depends on VPC)
18. **Internet Gateway** (depends on VPC)
19. **VPC** (destroyed last)

## Why We Don't Need Many Explicit Dependencies

### ❌ Don't Do This (Creates Circular Dependencies)

```hcl
# BAD: Circular dependency
module "vpc" {
  depends_on = [module.compute]  # ← VPC depends on compute
}
module "compute" {
  subnet_id = module.vpc.subnet_id  # ← Compute depends on VPC
}
```

```hcl
# BAD: Circular dependency
module "iam" {
  depends_on = [module.compute]  # ← IAM depends on compute
}
module "compute" {
  iam_instance_profile_name = module.iam.profile_name  # ← Compute depends on IAM
}
```

```hcl
# BAD: Circular dependency within module
resource "aws_internet_gateway" "igw" {
  depends_on = [aws_route_table.rt]  # ← IGW depends on route table
}
resource "aws_route_table" "rt" {
  route {
    gateway_id = aws_internet_gateway.igw.id  # ← Route table depends on IGW
  }
}
```

### ✅ Do This Instead

Let Terraform's implicit dependency graph handle it:

```hcl
# GOOD: Terraform infers the correct order
module "vpc" { }
module "compute" {
  subnet_id = module.vpc.subnet_id  # Terraform knows: VPC → Compute
}
```

## Common Dependency Issues and Solutions

### Issue 1: IGW Dependency Violation
**Error**: `DependencyViolation: The Internet Gateway 'igw-xxx' has dependencies and cannot be deleted`

**Root Cause**: Trying to delete IGW while:
- Route tables still reference it
- EC2 instances with public IPs are still running
- NAT Gateways are still active

**Solution**: ✅ Already handled by implicit dependencies
- Route tables reference IGW → destroyed first
- EC2 instances in subnets → destroyed before subnets
- Subnets reference VPC → destroyed before VPC
- IGW references VPC → destroyed before VPC

### Issue 2: Security Group Dependency Violation
**Error**: `DependencyViolation: resource sg-xxx has a dependent object`

**Root Cause**: Trying to delete security group while EC2 instances still use it

**Solution**: ✅ Already handled by implicit dependencies
- Launch template references security group
- ASG references launch template
- ASG destroyed → instances terminated → security group can be deleted

### Issue 3: IAM Instance Profile in Use
**Error**: `DeleteConflict: Cannot delete entity, must detach all policies first`

**Root Cause**: Trying to delete IAM instance profile while instances still use it

**Solution**: ✅ Already handled by implicit dependencies
- Launch template references instance profile
- ASG destroyed → instances terminated → instance profile can be deleted

## Validation

Run these commands to verify the configuration:

```bash
# Check for circular dependencies
terraform validate

# See the dependency graph
terraform graph | dot -Tsvg > graph.svg

# Preview destruction order
terraform plan -destroy
```

## Summary

✅ **All dependencies are properly managed through:**
1. Implicit dependencies (resource references) - 95% of cases
2. Strategic explicit dependencies (depends_on) - 5% of cases
   - ECS service depends on cluster capacity providers
   - ECS module depends on compute module

❌ **No circular dependencies**
❌ **No unnecessary explicit dependencies**
✅ **Safe destruction order guaranteed**
