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

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for resource deployment."
  type        = string
}

variable "pod_identity_version" {
  description = "Version of the EKS Pod Identity addon."
  type        = string
}

variable "cloudwatchContainerInsights_version" {
  description = "Version of the CloudWatch Container Insights addon."
  type        = string
}
