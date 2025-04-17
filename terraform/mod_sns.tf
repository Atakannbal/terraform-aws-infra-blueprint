module "sns" {
  count = var.enable_sns_module ? 1 : 0
  source       = "./modules/sns"
  project_name = var.project_name
  environment = var.environment

  cluster_name = local.cluster_name
  sns_subscriber_email_address = var.sns_subscriber_email_address
}