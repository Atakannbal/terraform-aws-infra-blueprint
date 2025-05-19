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

variable "sns_subscriber_email_address" {
  description = "Email address to subscribe to the SNS topic."
  type        = string
}