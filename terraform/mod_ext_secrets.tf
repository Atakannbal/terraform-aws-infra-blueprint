module "external_secrets" {
  count                         = var.enable_external_secrets_module ? 1 : 0
  source                        = "./modules/ext-secrets"
  
  project_name                  = var.project_name
  environment                   = var.environment
  region                        = var.region

  account_id                    = data.aws_caller_identity.current.account_id
  external_secrets_helm_version = var.external_secrets_helm_version

  oidc_provider                 = module.eks[0].oidc_provider
  rds_secret_arn                = module.rds[0].db_instance_master_user_secret_arn
  rds_secret_name               = module.rds[0].db_instance_identifier

  depends_on                    = [module.eks, module.rds, module.cluster_autoscaler]
}
