variable "secrets_dbUser" {
  description = "Database username for the backend"
  type        = string
}

variable "secrets_dbPassword" {
  description = "Database password for the backend"
  type        = string
}

variable "secrets_dbUrl" {
  description = "Database URL for the backend"
  type        = string
}

variable "frontend_image" {
  description = "Frontend Docker image URL"
  type        = string
}

variable "backend_image" {
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