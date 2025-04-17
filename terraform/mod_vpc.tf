module "vpc" {
  count = var.enable_vpc_module ? 1 : 0
  source             = "./modules/vpc"
  cluster_name       = local.cluster_name
  project_name       = var.project_name
  environment        = var.environment

  region             = var.region
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}