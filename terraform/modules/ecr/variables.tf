variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the ECR repositories"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Whether to force delete the repositories"
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment for the ECR repositories (e.g., dev, prod)"
  type        = string
}