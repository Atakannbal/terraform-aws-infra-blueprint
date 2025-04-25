variable "account_id" {
    description = "AWS Account ID"
    type = string
}

variable "oidc_provider" {
    description = "OIDC Provider"
    type = string
}

variable "domain_name" {
    description = "Domain name for ExternalDNS"
    type = string
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type = string
}

variable "region" {
    description = "The AWS region to deploy the VPC"
    type = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type = string
}

variable "project_name" {
    description = "The name of the project"
    type = string
}

variable "environment" {
    description = "The environment (e.g., dev, staging, prod)"
    type = string
}

variable "eks_external_dns_version" {
    description = "Version of the External DNS Helm chart"
    type = string
}