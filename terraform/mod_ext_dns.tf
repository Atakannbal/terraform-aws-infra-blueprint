module "ext-dns" {
  count = var.enable_eks_external_dns ? 1 : 0
  source = "./modules/ext-dns"
  project_name = var.project_name
  environment = var.environment
  
  account_id = data.aws_caller_identity.current.account_id
  oidc_provider = module.eks[0].oidc_provider
  domain_name = var.public_domain
  cluster_name = local.cluster_name
  vpc_id = module.vpc[0].vpc_id
  region = var.region
  eks_external_dns_version = var.eks_external_dns_version
  
  depends_on = [module.eks]
}