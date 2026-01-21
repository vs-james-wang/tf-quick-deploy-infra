# SRE Spin Up EC2 - Modular Terraform Project

This project has been refactored into a modular structure for better maintainability and reusability.

## Project Structure

```
.
├── main.tf                    # Root module that orchestrates all sub-modules
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
├── providers.tf               # Provider configuration
├── terraform.tfvars           # Variable values
├── main.tf.backup            # Backup of original monolithic main.tf
└── modules/
    ├── vpc/                   # VPC, subnets, IGW, route tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/              # Security groups for EC2 instances
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                   # IAM roles and instance profiles
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/               # Launch template and Auto Scaling Group
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs/                   # ECS cluster, service, task definition
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds/                   # RDS PostgreSQL instance and security group
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Descriptions

### VPC Module (`modules/vpc`)
- Creates VPC with DNS support enabled
- Provisions two public subnets in different AZs
- Sets up Internet Gateway
- Configures route tables and associations
- **Outputs**: VPC ID, subnet IDs, IGW ID, route table ID

### Security Module (`modules/security`)
- Creates security group for EC2 instances
- Configures SSH access (conditional based on allowed CIDRs)
- Allows HTTP traffic on port 80
- **Outputs**: Security group ID

### IAM Module (`modules/iam`)
- Creates IAM role for ECS EC2 instances
- Creates IAM role for ECS task execution
- Sets up instance profile
- **Outputs**: Role ARNs, instance profile name

### Compute Module (`modules/compute`)
- Creates launch template with ECS-optimized AMI
- Provisions Auto Scaling Group
- Configures user data for ECS cluster registration
- **Outputs**: Launch template ID, ASG name and ARN

### ECS Module (`modules/ecs`)
- Creates ECS cluster
- Sets up capacity provider linked to ASG
- Defines task definition for nginx container
- Creates ECS service
- **Outputs**: Cluster name/ID, service name, capacity provider name

### RDS Module (`modules/rds`)
- Creates DB subnet group
- Sets up RDS security group
- Provisions PostgreSQL RDS instance
- **Outputs**: RDS endpoint, port, database name

## Dependency Management

The modules are configured with explicit dependencies to ensure proper creation and destruction order:

### Creation Order:
1. VPC → Security Groups → IAM
2. Compute (ASG)
3. ECS (Cluster, Service)
4. RDS

### Destruction Order (reverse):
1. RDS
2. ECS Service → Capacity Provider
3. ASG (EC2 instances)
4. Security Groups → IAM
5. VPC resources (subnets, IGW, route tables)
6. VPC

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan Changes
```bash
terraform plan
```

### Apply Configuration
```bash
terraform apply
```

### Destroy Resources
```bash
terraform destroy
```

## Benefits of Modular Structure

1. **Separation of Concerns**: Each module handles a specific aspect of the infrastructure
2. **Reusability**: Modules can be reused across different environments or projects
3. **Maintainability**: Easier to update and debug individual components
4. **Testing**: Each module can be tested independently
5. **Collaboration**: Team members can work on different modules simultaneously
6. **Clear Dependencies**: Module structure makes resource dependencies explicit

## Migration Notes

- The original `main.tf` has been backed up to `main.tf.backup`
- All functionality remains the same, just organized differently
- No changes to `variables.tf` or `terraform.tfvars` are required
- Run `terraform init` after the refactoring to initialize the modules
