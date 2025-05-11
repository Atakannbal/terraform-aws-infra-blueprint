output "frontend_ecr_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr[0].frontend_repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr[0].backend_repository_url
}

output "name_servers" {
  description = "Name servers for the Route53 hosted zone"
output "bastion_ssh_command" {
  description = "Command to SSH into the bastion host"
  value       = local.bastion_exists ? module.bastion[0].bastion_ssh_command : "No bastion host available"  
}

