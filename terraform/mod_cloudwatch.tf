module "cloudwatch" {
  count = var.enable_eks_cloudwatch_logs ? 1 : 0
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  environment = var.environment

  cluster_name = local.cluster_name
  vpc_id       = module.vpc[0].vpc_id
  region       = var.region
  eks_addon_podIdentity_version = var.eks_addon_podIdentity_version
  eks_addon_cloudwatchContainerInsights_version = var.eks_addon_cloudwatchContainerInsights_version

  depends_on = [module.alb.aws_load_balancer_controller]
}