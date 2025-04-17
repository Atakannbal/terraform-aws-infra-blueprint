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
  value = length(module.ext-dns) > 0 ? module.ext-dns[0].route53_name_servers : []
}

