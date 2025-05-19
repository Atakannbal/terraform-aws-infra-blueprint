output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL of the OIDC issuer for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_role_name" {
  description = "IAM role name for EKS worker nodes"
  value       = aws_iam_role.eks_node_group_role.name
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}


