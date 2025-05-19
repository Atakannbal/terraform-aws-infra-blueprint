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

  subnet_ids           = module.vpc[0].private_subnets

  depends_on           = [ module.vpc ]
}