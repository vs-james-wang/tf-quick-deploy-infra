# SRE Spin Up EC2 - Modular Terraform Project

Modular Terraform project for spinning up ECS on EC2 with RDS PostgreSQL. All configuration is driven from `terraform.tfvars`.

## Project Structure

```
.
├── main.tf                    # Root module that orchestrates all sub-modules
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
├── providers.tf               # Provider and S3 backend configuration
├── terraform.tfvars           # All configurable values
└── modules/
    ├── vpc/                   # VPC, subnets, IGW, route tables
    ├── security/              # Security groups for EC2 instances
    ├── iam/                   # IAM roles and instance profiles
    ├── compute/               # Launch template and Auto Scaling Group
    ├── ecs/                   # ECS cluster, service, task definition
    └── rds/                   # RDS PostgreSQL instance and security group
```

## Modules

### VPC (`modules/vpc`)
- VPC with DNS support
- Two public subnets across AZs (second subnet CIDR auto-calculated via `cidrsubnet`)
- Internet Gateway, route tables, and associations

### Security (`modules/security`)
- EC2 security group with SSH (conditional) and HTTP ingress

### IAM (`modules/iam`)
- ECS EC2 instance role and instance profile
- ECS task execution role

### Compute (`modules/compute`)
- Launch template with ECS-optimized Amazon Linux 2023 AMI
- Auto Scaling Group with `force_delete = true` to prevent stuck destroys
- Configurable EBS volume size

### ECS (`modules/ecs`)
- ECS cluster with capacity provider linked to ASG
- Task definition and service with configurable container image, port, CPU, and memory

### RDS (`modules/rds`)
- DB subnet group and RDS-specific security group
- PostgreSQL instance with configurable engine version, storage, and accessibility

## Configuration

All values are configured in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Name prefix for all resources | `sre-test` |
| `aws_region` | AWS region | `us-east-1` |
| `vpc_cidr` | VPC CIDR block | `172.16.0.0/16` |
| `public_subnet_cidr` | First subnet CIDR (must be within VPC CIDR) | `172.16.1.0/24` |
| `availability_zone` | Primary AZ | `us-east-1a` |
| `instance_type` | EC2 instance type | `t3.small` |
| `ebs_volume_size` | EBS volume size in GB | `50` |
| `asg_min_size` / `max` / `desired` | ASG scaling config | `1` / `1` / `1` |
| `key_name` | SSH key pair name (must exist in AWS) | - |
| `allowed_ssh_cidrs` | CIDRs allowed SSH access | `[]` |
| `ecs_task_cpu` | CPU units for ECS task | `256` |
| `ecs_task_memory` | Memory (MB) for ECS task | `512` |
| `ecs_container_image` | Container image | `nginx:latest` |
| `ecs_desired_count` | Number of ECS tasks | `1` |
| `ecs_container_port` | Container/host port | `80` |
| `db_engine_version` | PostgreSQL version | `15` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |
| `db_allocated_storage` | RDS storage in GB | `20` |
| `db_publicly_accessible` | RDS public access | `true` |
| `db_password` | Database password (use `TF_VAR_db_password` env var instead) | - |

## Usage

```bash
# Initialize
terraform init

# Preview changes
terraform plan

# Apply
terraform apply

# Destroy (recommended order to avoid stuck resources)
terraform destroy -target=module.ecs
terraform destroy -target=module.compute
terraform destroy
```

## Recommended Destroy Order

ECS capacity providers hold references to the ASG, which can cause destroys to hang. To avoid this:

1. ECS service
2. Capacity provider association
3. Capacity provider
4. Cluster
5. Compute (ASG)
6. Everything else

Or use targeted destroys:

```bash
terraform destroy -target=module.ecs.aws_ecs_service.main
terraform destroy -target=module.ecs.aws_ecs_cluster_capacity_providers.main
terraform destroy -target=module.ecs.aws_ecs_capacity_provider.main
terraform destroy -target=module.ecs.aws_ecs_cluster.main
terraform destroy -target=module.compute
terraform destroy
```

## State Backend

State is stored in S3:
- **Bucket**: `sre-spin-up-test-resources`
- **Key**: `terraform.tfstate`
- **Region**: `us-west-2`
- **Encryption**: enabled
