# State Migration Guide

## Overview
This guide helps you migrate your existing Terraform state from the monolithic structure to the new modular structure.

## ⚠️ Important Warning
**DO NOT run `terraform apply` immediately after refactoring!** Terraform will try to destroy all existing resources and recreate them, causing downtime.

## Migration Options

### Option 1: Fresh Deployment (Recommended for New Environments)
If this is a new environment or you can afford to recreate resources:

```bash
# Destroy old infrastructure
terraform destroy

# Initialize new modules
terraform init

# Apply new modular configuration
terraform apply
```

### Option 2: State Migration (For Production/Existing Environments)

#### Step 1: Backup Everything
```bash
# Backup state file
terraform state pull > terraform.tfstate.backup.json
cp terraform.tfstate terraform.tfstate.backup

# Backup configuration
cp main.tf.backup main.tf.original
```

#### Step 2: Initialize New Modules
```bash
terraform init -upgrade
```

#### Step 3: Move Resources to Modules

Run these commands to move each resource from the root module to its respective module:

```bash
# VPC Resources
terraform state mv aws_vpc.main module.vpc.aws_vpc.main
terraform state mv aws_internet_gateway.main module.vpc.aws_internet_gateway.main
terraform state mv aws_subnet.public module.vpc.aws_subnet.public
terraform state mv aws_subnet.public_2 module.vpc.aws_subnet.public_2
terraform state mv aws_route_table.public module.vpc.aws_route_table.public
terraform state mv aws_route_table_association.public module.vpc.aws_route_table_association.public
terraform state mv aws_route_table_association.public_2 module.vpc.aws_route_table_association.public_2

# Security Resources
terraform state mv aws_security_group.instance module.security.aws_security_group.instance

# IAM Resources
terraform state mv aws_iam_role.ecs_instance module.iam.aws_iam_role.ecs_instance
terraform state mv aws_iam_role_policy_attachment.ecs_instance module.iam.aws_iam_role_policy_attachment.ecs_instance
terraform state mv aws_iam_instance_profile.ecs_instance module.iam.aws_iam_instance_profile.ecs_instance
terraform state mv aws_iam_role.ecs_task_execution module.iam.aws_iam_role.ecs_task_execution
terraform state mv aws_iam_role_policy_attachment.ecs_task_execution module.iam.aws_iam_role_policy_attachment.ecs_task_execution

# Compute Resources
terraform state mv aws_launch_template.main module.compute.aws_launch_template.main
terraform state mv aws_autoscaling_group.main module.compute.aws_autoscaling_group.main

# ECS Resources
terraform state mv aws_ecs_cluster.main module.ecs.aws_ecs_cluster.main
terraform state mv aws_ecs_capacity_provider.main module.ecs.aws_ecs_capacity_provider.main
terraform state mv aws_ecs_cluster_capacity_providers.main module.ecs.aws_ecs_cluster_capacity_providers.main
terraform state mv aws_ecs_task_definition.main module.ecs.aws_ecs_task_definition.main
terraform state mv aws_ecs_service.main module.ecs.aws_ecs_service.main

# RDS Resources
terraform state mv aws_db_subnet_group.main module.rds.aws_db_subnet_group.main
terraform state mv aws_security_group.rds module.rds.aws_security_group.rds
terraform state mv aws_db_instance.main module.rds.aws_db_instance.main
```

#### Step 4: Verify Migration
```bash
# This should show NO changes
terraform plan
```

If the plan shows changes, review them carefully. There should be no resource replacements.

#### Step 5: Apply (if needed)
```bash
# Only if plan shows minor acceptable changes
terraform apply
```

### Option 3: Automated Migration Script

Save this script as `migrate_state.sh`:

```bash
#!/bin/bash
set -e

echo "Starting state migration..."

# Backup
echo "Creating backups..."
terraform state pull > terraform.tfstate.backup.json
cp terraform.tfstate terraform.tfstate.backup

# VPC Resources
echo "Migrating VPC resources..."
terraform state mv aws_vpc.main module.vpc.aws_vpc.main
terraform state mv aws_internet_gateway.main module.vpc.aws_internet_gateway.main
terraform state mv aws_subnet.public module.vpc.aws_subnet.public
terraform state mv aws_subnet.public_2 module.vpc.aws_subnet.public_2
terraform state mv aws_route_table.public module.vpc.aws_route_table.public
terraform state mv aws_route_table_association.public module.vpc.aws_route_table_association.public
terraform state mv aws_route_table_association.public_2 module.vpc.aws_route_table_association.public_2

# Security Resources
echo "Migrating security resources..."
terraform state mv aws_security_group.instance module.security.aws_security_group.instance

# IAM Resources
echo "Migrating IAM resources..."
terraform state mv aws_iam_role.ecs_instance module.iam.aws_iam_role.ecs_instance
terraform state mv aws_iam_role_policy_attachment.ecs_instance module.iam.aws_iam_role_policy_attachment.ecs_instance
terraform state mv aws_iam_instance_profile.ecs_instance module.iam.aws_iam_instance_profile.ecs_instance
terraform state mv aws_iam_role.ecs_task_execution module.iam.aws_iam_role.ecs_task_execution
terraform state mv aws_iam_role_policy_attachment.ecs_task_execution module.iam.aws_iam_role_policy_attachment.ecs_task_execution

# Compute Resources
echo "Migrating compute resources..."
terraform state mv aws_launch_template.main module.compute.aws_launch_template.main
terraform state mv aws_autoscaling_group.main module.compute.aws_autoscaling_group.main

# ECS Resources
echo "Migrating ECS resources..."
terraform state mv aws_ecs_cluster.main module.ecs.aws_ecs_cluster.main
terraform state mv aws_ecs_capacity_provider.main module.ecs.aws_ecs_capacity_provider.main
terraform state mv aws_ecs_cluster_capacity_providers.main module.ecs.aws_ecs_cluster_capacity_providers.main
terraform state mv aws_ecs_task_definition.main module.ecs.aws_ecs_task_definition.main
terraform state mv aws_ecs_service.main module.ecs.aws_ecs_service.main

# RDS Resources
echo "Migrating RDS resources..."
terraform state mv aws_db_subnet_group.main module.rds.aws_db_subnet_group.main
terraform state mv aws_security_group.rds module.rds.aws_security_group.rds
terraform state mv aws_db_instance.main module.rds.aws_db_instance.main

echo "Migration complete!"
echo "Running terraform plan to verify..."
terraform plan

echo ""
echo "If the plan shows no changes, migration was successful!"
echo "If there are changes, review them carefully before applying."
```

Make it executable and run:
```bash
chmod +x migrate_state.sh
./migrate_state.sh
```

## Troubleshooting

### Issue: "Resource not found in state"
**Solution**: The resource might have already been moved or doesn't exist. Check with:
```bash
terraform state list
```

### Issue: "Plan shows resource replacements"
**Solution**: This usually means there's a configuration mismatch. Compare the old and new configurations carefully.

### Issue: "Module not found"
**Solution**: Run `terraform init` to initialize the modules.

### Issue: "Circular dependency detected"
**Solution**: This has been fixed in the modules. Make sure you're using the latest module code.

## Rollback Procedure

If something goes wrong:

```bash
# Restore state file
cp terraform.tfstate.backup terraform.tfstate

# Restore old configuration
cp main.tf.backup main.tf

# Reinitialize
terraform init

# Verify
terraform plan
```

## Best Practices

1. **Always backup** before migration
2. **Test in dev/staging** before production
3. **Run during maintenance window** if possible
4. **Have rollback plan ready**
5. **Document any manual changes** made during migration
6. **Verify outputs** after migration

## Post-Migration Checklist

- [ ] All resources migrated successfully
- [ ] `terraform plan` shows no changes
- [ ] Outputs are correct
- [ ] Application is functioning normally
- [ ] State file is backed up
- [ ] Team is notified of new structure
- [ ] Documentation is updated
- [ ] CI/CD pipelines are updated (if applicable)
