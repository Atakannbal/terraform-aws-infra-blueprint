# Generate a random string suffix for unique resource names
resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
}

# Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length           = 50
  special          = false

  lifecycle {
    ignore_changes = [
      special,
      length
    ]
  }
}

# Create a Secrets Manager secret to store the RDS credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-${var.environment}-credentials-${random_string.suffix.result}"
}

# Create a KMS key for RDS encryption
resource "aws_kms_key" "rds_key" {
  description         = "KMS key for RDS encryption"
  enable_key_rotation = true
}

# Create an alias for the KMS key
resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/${var.project_name}-${var.environment}-rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-${var.environment}-rds-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id, var.eks_sg_id, var.bastion_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the backend application
resource "aws_security_group" "backend_sg" {
  name   = "${var.project_name}-${var.environment}-backend-sg"
  vpc_id = var.vpc_id
  # Allow inbound traffic on port 8080 from public subnets (e.g., from ALB)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.public_subnets_cidr_blocks
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.project_name}-${var.environment}-rds-enhanced-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach the AmazonRDSEnhancedMonitoringRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Create an RDS instance using the terraform-aws-modules/rds/aws module
module "rds" {
  source                 = "terraform-aws-modules/rds/aws"
  version                = "~> 6.0"
  identifier             = "${var.project_name}-${var.environment}-calculator-db"
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  family                 = "postgres15"
  instance_class         = var.rds_db_instance_class
  allocated_storage      = var.rds_instance_allocated_storage
  db_name                = var.rds_db_default_name
  username               = var.rds_master_credentials_user
  password               = random_password.rds_password.result
  port                   = var.rds_port
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_ids             = var.subnet_ids
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  manage_master_user_password = false
  kms_key_id             = aws_kms_key.rds_key.arn
  backup_retention_period = 1
  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring.arn
}


# Create a new version of the Secrets Manager secret with the RDS credentials
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = module.rds.db_instance_username
    password = random_password.rds_password.result
    host     = module.rds.db_instance_endpoint
    dbname   = module.rds.db_instance_name
  })

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
