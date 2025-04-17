module "metrics" {
  count = var.enable_eks_metrics_server ? 1 : 0
  source       = "./modules/metrics"
  project_name = var.project_name
  environment = var.environment
  eks_metrics_server_version = var.eks_metrics_server_version
  
  depends_on = [module.eks, module.eks.eks_managed_node_groups]
}