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

variable "image_tag_mutability" {
  description = "The tag mutability setting for the ECR repositories."
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Whether to force delete the repositories."
  type        = bool
  default     = true
}