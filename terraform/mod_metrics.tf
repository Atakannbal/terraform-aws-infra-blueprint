module "metrics" {
  count                    = var.enable_metrics_server_module ? 1 : 0
  source                   = "./modules/metrics"
  project_name             = var.project_name
  environment              = var.environment
  region                   = var.region

  eks_metrics_server_version = var.eks_metrics_server_version

  depends_on               = [module.eks]
}