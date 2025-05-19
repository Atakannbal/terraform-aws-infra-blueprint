variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
}

variable "region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

# **************************************************

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy the Cluster Autoscaler"
  type        = string
  default     = "kube-system"
}

variable "eks_cluster_autoscaler_version" {
  description = "Version of the Cluster Autoscaler to deploy"
  type        = string
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}



