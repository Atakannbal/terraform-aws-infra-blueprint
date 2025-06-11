module "route53" {
  count                        = var.enable_route53_module ? 1 : 0
  source                       = "./modules/route53"
  hosted_zone_domain_name      = var.hosted_zone_domain_name
}