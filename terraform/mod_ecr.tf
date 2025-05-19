module "ecr" {
  count        = var.enable_ecr_module ? 1 : 0
  source       = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  region       = var.region
}