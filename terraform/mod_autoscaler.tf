module "cluster_autoscaler" {
  count                        = var.enable_cluster_autoscaler_module ? 1 : 0
  source                       = "./modules/cluster-autoscaler"

  project_name                 = var.project_name
  environment                  = var.environment
  region                       = var.region

  account_id                   = data.aws_caller_identity.current.account_id
  eks_cluster_version          = var.eks_cluster_version
  eks_cluster_autoscaler_version = var.eks_cluster_autoscaler_version

  cluster_name                 = module.eks[0].cluster_name
  oidc_provider_arn            = module.eks[0].oidc_provider_arn
  cluster_endpoint             = module.eks[0].cluster_endpoint
  oidc_provider                = module.eks[0].oidc_provider

  depends_on                   = [ module.vpc, module.eks ]
}
