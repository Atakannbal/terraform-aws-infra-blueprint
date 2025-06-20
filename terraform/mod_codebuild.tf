module "codebuild" {
  count                         = var.enable_codebuild_module ? 1 : 0
  source                        = "./modules/codebuild"
  
  project_name                  = var.project_name
  environment                   = var.environment
  region                        = var.region
  vpc_id                        = module.vpc[0].vpc_id

  compute_type                  = var.codebuild_compute_type
  image                         = var.codebuild_image
  github_repo                   = var.codebuild_github_repo
  github_pat                    = jsondecode(data.aws_secretsmanager_secret_version.codebuild_version[0].secret_string)["github_pat"]
  
  cluster_name                  = local.cluster_name
  
  subnet_ids                    = module.vpc[0].private_subnets

  depends_on                    = [module.vpc]
  
}