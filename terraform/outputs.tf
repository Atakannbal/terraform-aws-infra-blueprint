output "name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value = local.ext_dns_exists ? module.ext-dns[0].route53_name_servers : []
}
output "bastion_ssh_command" {
  description = "Command to SSH into the bastion host"
  value       = local.bastion_exists ? module.bastion[0].bastion_ssh_command : "No bastion host available"  
}

