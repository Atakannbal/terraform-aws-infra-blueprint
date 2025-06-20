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
  description = "VPC ID for EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster."
  type        = list(string)
}

variable "eks_instance_type" {
  description = "List of instance types for EKS nodes."
  type        = list(string)
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster."
  type        = string
}

variable "eks_nodes_count" {
  description = "Number of EKS nodes."
  type        = number
}

variable "eks_min_nodes_count" {
  description = "Minimum number of EKS nodes."
  type        = number
}

variable "eks_max_nodes_count" {
  description = "Maximum number of EKS nodes."
  type        = number
}

variable "cidr_external_access" {
  description = "List of CIDR blocks allowed external access to the cluster."
  type        = list(string)
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild role."
  type        = string
}

variable "codebuild_sg_id" {
  description = "SG Id of codebuild."
  type        = string
}

variable "vpc_endpoints_sg_id" {
  description = "Security group ID for VPC endpoints."
  type        = string
}
