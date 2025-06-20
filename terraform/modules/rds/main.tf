####################################################################################################
# This module provisions a secure, encrypted PostgreSQL RDS instance with supporting resources.
# Includes KMS key, security groups, IAM role for enhanced monitoring, and all required networking.
# Uses terraform-aws-modules/rds/aws for best practices and maintainability.
####################################################################################################

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
  manage_master_user_password = true
  port                   = var.rds_port
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_ids             = var.subnet_ids
  create_db_subnet_group = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn
  backup_retention_period = 1
  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring.arn
  master_user_password_rotation_duration = "30d"
}

resource "aws_kms_key" "rds_key" {
  description         = "KMS key for RDS encryption"
  enable_key_rotation = true
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/${var.project_name}-${var.environment}-rds-encryption-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = concat(
      [aws_security_group.backend_sg.id],
      var.bastion_sg_id != null ? [var.bastion_sg_id] : [],
      var.eks_sg_id != null ? [var.eks_sg_id] : []
    )
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  name   = "${var.project_name}-${var.environment}-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.public_subnets_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}