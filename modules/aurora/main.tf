# Aurora Security Group
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Security group for Aurora cluster"
  vpc_id      = var.vpc_id

  # Database access from allowed CIDRs
  dynamic "ingress" {
    for_each = length(var.allowed_cidrs) > 0 ? [1] : []
    content {
      description = "Database access from allowed CIDRs"
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  # Database access from EC2 instances
  ingress {
    description     = "Database access from EC2"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.instance_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-aurora-sg"
  }
}

# DB Subnet Group for Aurora
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-aurora-subnet-group"
  }
}

# Aurora Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project_name}-aurora-cluster"
  engine             = var.engine
  engine_mode        = "provisioned"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Serverless v2 scaling configuration (minimum resources)
  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_capacity
    max_capacity = var.serverless_max_capacity
  }

  # Lab/testing settings
  skip_final_snapshot = true
  apply_immediately   = true

  # Optional: enable deletion protection for non-lab environments
  deletion_protection = var.deletion_protection

  tags = {
    Name                 = "${var.project_name}-aurora-cluster"
    "lights-out:managed" = "true"
    "lights-out:group"   = "sre-test"
    "Scheduler"          = "offhours"
  }
}

# Aurora Serverless v2 Instance
resource "aws_rds_cluster_instance" "main" {
  identifier         = "${var.project_name}-aurora-instance-1"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  publicly_accessible = var.publicly_accessible

  tags = {
    Name                 = "${var.project_name}-aurora-instance-1"
    "lights-out:managed" = "true"
    "lights-out:group"   = "sre-test"
    "Scheduler"          = "offhours"
  }
}
