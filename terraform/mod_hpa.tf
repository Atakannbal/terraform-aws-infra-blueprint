module "hpa" {
  count        = var.enable_hpa_module ? 1 : 0
  source       = "./modules/hpa"
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  depends_on   = [module.app, module.eks]
}