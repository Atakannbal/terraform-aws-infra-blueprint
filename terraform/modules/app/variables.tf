variable "project_name" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "db_user" {
  description = "Database username for the backend"
  type        = string
}

variable "db_password" {
  description = "Database password for the backend"
  type        = string
}

variable "db_url" {
  description = "Database URL for the backend"
  type        = string
}

variable "frontend_image_url" {
  description = "Frontend Docker image URL"
  type        = string
}

variable "backend_image_url" {
  description = "Backend Docker image URL"
  type        = string
}

variable "frontend_hostname" {
  description = "Hostname for the frontend Ingress"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "projectName" {
  description = "Project name"
  type        = string
}