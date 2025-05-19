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

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider for the EKS cluster."
  type        = string
}

variable "hosted_zone_domain_name" {
  description = "Domain name for the hosted zone used by ExternalDNS."
  type        = string
}

variable "cloudfront_domain_name" {
  description = "Domain name for CloudFront distribution."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ExternalDNS deployment."
  type        = string
}

variable "eks_external_dns_version" {
  description = "Version of the ExternalDNS Helm chart."
  type        = string
}