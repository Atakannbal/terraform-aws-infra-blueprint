module "ext-dns" {
  count                     = var.enable_external_dns_module ? 1 : 0
  source                    = "./modules/external-dns"
  
  project_name              = var.project_name
  environment               = var.environment
  region                    = var.region
  vpc_id                    = module.vpc[0].vpc_id

  cluster_name              = module.eks[0].cluster_name

  account_id                = data.aws_caller_identity.current.account_id
  hosted_zone_domain_name   = var.hosted_zone_domain_name
  cloudfront_domain_name    = var.cloudfront_domain_name
  eks_external_dns_version  = var.eks_external_dns_version

  oidc_provider             = module.eks[0].oidc_provider

  depends_on                = [module.vpc, module.eks, module.cluster_autoscaler]
}