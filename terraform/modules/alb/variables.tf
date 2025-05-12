variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the resources will be deployed."
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL for IAM roles."
  type        = string
}

variable "account_id" {
  description = "AWS Account ID."
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "eks_aws_lb_controller_version" {
  description = "Version of the AWS Load Balancer Controller for EKS."
  type        = string
}