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

variable "oidc_provider" {
  description = "OIDC provider for the EKS cluster."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "alb_controller_version" {
  description = "Version of the AWS Load Balancer Controller for EKS."
  type        = string
}