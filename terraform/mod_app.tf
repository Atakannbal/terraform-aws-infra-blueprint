module "app" {
  count = var.enable_app_module ? 1 : 0
  source = "./modules/app"
  projectName         = var.project_name

  secrets_dbUser      = local.db_secrets.username
  secrets_dbPassword  = local.db_secrets.password
  secrets_dbUrl       = local.db_url_with_prefix
  frontend_image      = local.frontend_image
  backend_image       = local.backend_image
  frontend_hostname   = var.public_domain
  region              = var.region

  depends_on = [module.eks, module.alb.aws_load_balancer_controller, module.ext-dns.external_dns]
}