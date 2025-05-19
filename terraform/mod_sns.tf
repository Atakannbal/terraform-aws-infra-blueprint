module "sns" {
  count                        = var.enable_sns_module ? 1 : 0
  source                       = "./modules/sns"
  project_name                 = var.project_name
  environment                  = var.environment
  region                       = var.region

  cluster_name                 = module.eks[0].cluster_name
  
  sns_subscriber_email_address = var.sns_subscriber_email_address
}