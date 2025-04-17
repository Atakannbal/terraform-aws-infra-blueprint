module "hpa" {
  count = var.enable_hpa_module ? 1 : 0
  source       = "./modules/hpa"
  project_name = var.project_name
  environment = var.environment

  depends_on = [module.app]
}