module "eks" {
  count                = var.enable_eks_module ? 1 : 0
  source               = "./modules/eks"
  
  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  vpc_id               = module.vpc[0].vpc_id

  cluster_name         = local.cluster_name
  cidr_external_access = var.cidr_external_access
  eks_instance_type    = var.eks_instance_type
  eks_cluster_version  = var.eks_cluster_version
  eks_nodes_count      = var.eks_nodes_count
  eks_min_nodes_count  = var.eks_min_nodes_count
  eks_max_nodes_count  = var.eks_max_nodes_count

  codebuild_role_arn   = local.codebuild_exists ? module.codebuild[0].codebuild_role_arn : null
  codebuild_sg_id      = local.codebuild_exists ? module.codebuild[0].codebuild_sg_id : null
  vpc_endpoints_sg_id  = module.vpc[0].vpc_endpoints_security_group_id
  subnet_ids           = module.vpc[0].private_subnets

  depends_on           = [ module.vpc, module.codebuild ]
}