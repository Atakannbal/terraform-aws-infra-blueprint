variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable project_name {
  description = "Project name"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "hosted_zone_domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "load_balancer_domain_name" {
  description = "Domain name for the load balancer"
  type = string
}

variable "cloudfront_domain_name" {
  description = "Domain name for CloudFront"
  type = string
}


variable "enable_vpc_module" {
  description = "Enable VPC module"
  type        = bool
}

variable "enable_app_module" {
  description = "Enable application module"
  type        = bool
}

variable "enable_sns_module" {
  description = "Enable SNS module"
  type        = bool
}

variable "enable_hpa_module" {
  description = "Enable HPA module"
  type        = bool
}

variable "enable_ecr_module" {
  description = "Enable ECR module"
  type        = bool
}

variable "enable_bastion_module" {
  description = "Enable EC2 Bastion module"
  type        = bool
}

variable "enable_rds_module" {
  description = "Enable RDS module"
  type        = bool
}

variable "enable_eks_module" {
  description = "Enable EKS module"
  type        = bool
}

variable "enable_alb_module" {
  description = "Enable AWS Load Balancer Controller for EKS"
  type        = bool
}

variable "enable_external_dns_module" {
  description = "Enable External DNS for EKS"
  type        = bool
}

variable "enable_cloudwatch_module" {
  description = "Enable CloudWatch Logs for EKS"
  type        = bool
}

variable "enable_metrics_server_module" {
  description = "Enable Metrics Server for EKS"
  type        = bool
}

variable "enable_cloudfront_module" {
  description = "Enable CloudFront for the application"
  type        = bool
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "cidr_external_access" {
  description = "CIDR blocks for external access"
  type        = list(string)
}

variable "cidr_bastion_access" {
  description = "CIDR blocks for bastion access"
  type        = list(string)
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "eks_instance_type" {
  description = "Instance types for EKS nodes"
  type        = list(string)
}

variable "eks_nodes_count" {
  description = "Number of EKS nodes"
  type        = number
}

variable "eks_min_nodes_count" {
  description = "Minimum number of EKS nodes"
  type        = number
}

variable "eks_max_nodes_count" {
  description = "Maximum number of EKS nodes"
  type        = number
}

variable "alb_controller_version" {
  description = "Version of AWS Load Balancer Controller for EKS"
  type        = string
}

variable "eks_external_dns_version" {
  description = "Version of External DNS for EKS"
  type        = string
}

variable "eks_metrics_server_version" {
  description = "Version of Metrics Server for EKS"
  type        = string
}

variable "eks_addon_pod_identity_version" {
  description = "Version of Pod Identity add-on for EKS"
  type        = string
}

variable "eks_addon_cloudwatch_containerinsights_version" {
  description = "Version of CloudWatch Container Insights add-on for EKS"
  type        = string
}

variable "rds_engine" {
  description = "RDS engine type"
  type        = string
}

variable "rds_engine_version" {
  description = "Version of the RDS engine"
  type        = string
}

variable "rds_db_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

variable "rds_instance_allocated_storage" {
  description = "Allocated storage for RDS instance"
  type        = number
}

variable "rds_port" {
  description = "Port for RDS"
  type        = number
}

variable "rds_db_default_name" {
  description = "Default database name for RDS"
  type        = string
}

variable "rds_master_credentials_user" {
  description = "Master username for RDS"
  type        = string
}

variable "sns_subscriber_email_address" {
  description = "Email address for SNS subscription"
  type        = string
}