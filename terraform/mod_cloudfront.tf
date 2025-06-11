module "cloudfront" {
  count                     = var.enable_cloudfront_module ? 1 : 0
  source                    = "./modules/cloudfront"
  
  project_name              = var.project_name
  environment               = var.environment
  region                    = var.region
  vpc_id                    = module.vpc[0].vpc_id

  cloudfront_domain_name    = var.cloudfront_domain_name
  load_balancer_domain_name = var.load_balancer_domain_name
  route53_zone_id           = module.route53[0].route53_zone_id

  providers = {
    aws = aws.us_east_1
  }

  depends_on = [module.vpc, module.eks, module.alb, module.ext-dns, module.app, module.route53]
}