variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment."
  type        = string
}

# **************************************************

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the VPC."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets."
  type        = list(string)
}

