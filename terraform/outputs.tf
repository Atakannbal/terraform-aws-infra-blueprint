output "name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value = local.route53_exists ? module.route53[0].route53_name_servers : ["No name servers available"]
}

output "bastion_ssh_command" {
  description = "Command to SSH into the bastion host"
  value       = local.bastion_exists ? module.bastion[0].bastion_ssh_command : "No bastion host available"  
}

output "eks_update_kubeconfig_command" {
  description = "Command to update kubeconfig for the EKS cluster"
  value       = local.eks_exists ? "aws eks update-kubeconfig --name ${local.cluster_name} --region ${var.region}" : "EKS cluster not available"
}

