module "bastion" {
  count                = var.enable_bastion_module ? 1 : 0
  source               = "./modules/bastion"

  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  vpc_id               = module.vpc[0].vpc_id

  cidr_bastion_access  = var.cidr_bastion_access
  subnet_id            = module.vpc[0].public_subnets[0]
  eks_node_security_group_id = module.eks[0].node_security_group_id

  depends_on           = [module.vpc, module.eks]
}