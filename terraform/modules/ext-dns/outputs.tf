output "external_dns_role_arn" {
  description = "ARN of the IAM role for ExternalDNS"
  value       = aws_iam_role.external_dns.arn
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value       = aws_route53_zone.primary.name_servers
}

output "external_dns" {
    description = "Helm release for the AWS Load Balancer Controller"
    value       = helm_release.external_dns
}