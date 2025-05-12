module "app" {
  count = var.enable_app_module ? 1 : 0
  source = "./modules/app"
  project_name        = var.project_name

  db_user             = local.db_vars.username
  db_password         = local.db_vars.password
  db_url              = local.db_vars.db_url_with_prefix
  
  frontend_image_url  = local.frontend_image
  backend_image_url   = local.backend_image
  frontend_hostname   = var.public_domain
  region              = var.region

  depends_on = [module.eks, module.alb.aws_load_balancer_controller, module.ext-dns.external_dns]
}