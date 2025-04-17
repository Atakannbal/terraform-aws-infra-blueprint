module "alb" {
  count = var.enable_eks_aws_lb_controller ? 1 : 0
  source = "./modules/alb"

  environment = var.environment
  project_name = var.project_name
  oidc_provider = module.eks[0].oidc_provider
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  cluster_name = local.cluster_name
  eks_aws_lb_controller_version = var.eks_aws_lb_controller_version

  depends_on = [module.eks, module.eks.eks_managed_node_groups]
}