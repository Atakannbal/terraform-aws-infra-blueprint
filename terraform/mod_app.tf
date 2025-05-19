module "app" {
  count                     = var.enable_app_module ? 1 : 0
  source                    = "./modules/app"

  project_name              = var.project_name
  environment               = var.environment
  region                    = var.region
  vpc_id                    = module.vpc[0].vpc_id

  db_url                    = local.rds_exists ? "jdbc:postgresql://${module.rds[0].db_instance_endpoint}/${module.rds[0].db_instance_name}" : ""

  alb_domain   = var.load_balancer_domain_name
  cloudfront_domain = var.cloudfront_domain_name

  route53_zone_id           = module.ext-dns[0].route53_zone_id
  frontend_image_url        = "${module.ecr[0].frontend_repository_url}:${var.frontend_tag}"
  backend_image_url         = "${module.ecr[0].backend_repository_url}:${var.backend_tag}"

  depends_on                = [module.vpc, module.eks, module.alb.aws_load_balancer_controller, module.ext-dns.external_dns, module.cluster_autoscaler]
}