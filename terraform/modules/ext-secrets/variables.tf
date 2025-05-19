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

variable "external_secrets_helm_version" {
  description = "Helm chart version for External Secrets Operator."
  type        = string
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider for the EKS cluster."
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the RDS secret in AWS Secrets Manager."
  type        = string
}

variable "rds_secret_name" {
  description = "Name of the RDS secret in AWS Secrets Manager."
  type        = string
}