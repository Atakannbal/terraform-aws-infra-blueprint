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

variable "db_url" {
  description = "Database URL for the backend."
  type        = string
}

variable "frontend_image_url" {
  description = "Frontend Docker image URL."
  type        = string
}

variable "backend_image_url" {
  description = "Backend Docker image URL."
  type        = string
}

variable "alb_domain" {
  description = "Hostname for the frontend Ingress"
  type        = string
}

variable "cloudfront_domain" {
  description = "Hostname for CloudFront distribution."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID."
  type        = string
}

variable "rds_secret_arn" {
  description = "Secret arn for RDS"
  type        = string
}