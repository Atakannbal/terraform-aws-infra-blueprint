#############################################################################################################
# This module provisions a Route 53 hosted zone for the specified domain. 
# force_destroy allows deletion of the hosted zone 
# even if it has records (use with caution)
#
# After creation, see the output and add the Route 53 NS (name server) records 
# to your domain registrar to delegate DNS resolution to Route 53. 
# Copy the NS records from the hosted zone and update them in your registrar's DNS settings for the domain.
#############################################################################################################

resource "aws_route53_zone" "primary" {
  name = var.hosted_zone_domain_name
  force_destroy = true
}