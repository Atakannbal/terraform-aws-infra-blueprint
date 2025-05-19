variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment."
  type        = string
}

# **************************************************

variable "cloudfront_domain_name" {
  description = "Domain name for the CloudFront distribution."
  type        = string
}

variable "load_balancer_domain_name" {
  description = "Domain name for the load balancer."
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the CloudFront distribution."
  type        = string
}