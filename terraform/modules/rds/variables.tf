variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment."
  type        = string
}

# **************************************************

variable "vpc_id" {
  description = "VPC ID for RDS deployment."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS."
  type        = list(string)
}

variable "eks_sg_id" {
  description = "EKS node security group ID."
  type        = string
  default     = null
}

variable "bastion_sg_id" {
  description = "Bastion host security group ID."
  type        = string
  default     = null
}

variable "public_subnets_cidr_blocks" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
}

variable "rds_engine" {
  description = "RDS engine type (e.g., postgres, mysql)."
  type        = string
}

variable "rds_engine_version" {
  description = "RDS engine version."
  type        = string
}

variable "rds_db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "rds_db_default_name" {
  description = "Default database name."
  type        = string
}

variable "rds_instance_allocated_storage" {
  description = "Allocated storage for RDS instance (in GB)."
  type        = number
}

variable "rds_port" {
  description = "Port for RDS instance."
  type        = number
}

variable "rds_master_credentials_user" {
  description = "Master username for RDS instance."
  type        = string
}
