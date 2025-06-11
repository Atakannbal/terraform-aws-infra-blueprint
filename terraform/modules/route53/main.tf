# Route 53 hosted zone for the domain
resource "aws_route53_zone" "primary" {
  name = var.hosted_zone_domain_name
  force_destroy = true # Allow deletion of the hosted zone even if it has records
}