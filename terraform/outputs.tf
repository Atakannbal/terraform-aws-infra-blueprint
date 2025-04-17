output "frontend_ecr_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr.backend_repository_url
}

output "name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value = module.ext-dns.route53_name_servers
}

