module "cloudwatch" {
  count                             = var.enable_cloudwatch_module ? 1 : 0
  source                            = "./modules/cloudwatch"
  
  project_name                      = var.project_name
  environment                       = var.environment
  region                            = var.region
  vpc_id                            = module.vpc[0].vpc_id

  cluster_name                      = module.eks[0].cluster_name

  pod_identity_version              = var.eks_addon_pod_identity_version
  cloudwatchContainerInsights_version = var.eks_addon_cloudwatch_containerinsights_version

  depends_on                        = [module.vpc, module.eks, module.cluster_autoscaler]
}