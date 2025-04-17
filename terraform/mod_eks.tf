module "eks" {
  count = var.enable_eks_module ? 1 : 0
  source          = "./modules/eks"
  
  cluster_name = local.cluster_name
  vpc_id = module.vpc[0].vpc_id
  subnet_ids = module.vpc[0].private_subnets
  cidr_external_access = var.cidr_external_access
  eks_instance_type = var.eks_instance_type
  eks_cluster_version = var.eks_cluster_version
}