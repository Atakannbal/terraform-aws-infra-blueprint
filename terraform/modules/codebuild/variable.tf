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

variable "compute_type" {
  description = "Compute type for CodeBuild."
  type        = string
}

variable "image" {
  description = "Docker image for CodeBuild."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for CodeBuild."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for CodeBuild."
  type        = list(string)
}

variable "github_pat" {
  description = "GitHub Personal Access Token."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}