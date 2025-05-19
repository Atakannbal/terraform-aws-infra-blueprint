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
  description = "VPC ID for the bastion host."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion host."
  type        = string
}

variable "cidr_bastion_access" {
  description = "List of CIDR blocks allowed to access the bastion host."
  type        = list(string)
}