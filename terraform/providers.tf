# Terraform configuration block to specify required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Kubernetes provider configuration to interact with the EKS cluster
provider "kubernetes" {
  host                   = try(module.eks[0].cluster_endpoint, null)
  cluster_ca_certificate = try(base64decode(module.eks[0].cluster_certificate_authority_data),null)
  token                  = try(data.aws_eks_cluster_auth.this[0].token, null)
}

# AWS provider configuration
provider "aws" {
  region = var.region
}

# Helm provider configuration for deploying Helm charts
provider "helm" {
  kubernetes {
    host                   = try(module.eks[0].cluster_endpoint, null)
    cluster_ca_certificate = try(base64decode(module.eks[0].cluster_certificate_authority_data), null)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--region", var.region]
    }
  }
}