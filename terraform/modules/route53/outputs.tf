output "route53_zone_id" {
  description = "Route53 hosted zone id"
  value = aws_route53_zone.primary.zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value       = aws_route53_zone.primary.name_servers
}
