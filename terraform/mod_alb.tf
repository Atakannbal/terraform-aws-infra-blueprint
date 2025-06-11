module "alb" {
  count                       = var.enable_alb_module ? 1 : 0
  source                      = "./modules/alb"

  project_name                = var.project_name
  environment                 = var.environment
  region                      = var.region

  cluster_name                = module.eks[0].cluster_name

  account_id                  = data.aws_caller_identity.current.account_id
  alb_controller_version      = var.alb_controller_version

  oidc_provider               = module.eks[0].oidc_provider

  depends_on                  = [module.vpc, module.eks]
}