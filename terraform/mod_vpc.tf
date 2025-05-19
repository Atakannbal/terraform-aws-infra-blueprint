module "vpc" {
  count = var.enable_vpc_module ? 1 : 0
  source             = "./modules/vpc"
  project_name       = var.project_name
  environment        = var.environment

  cluster_name       = local.cluster_name
  
  region             = var.region
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}