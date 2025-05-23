module "rds" {
  count                        = var.enable_rds_module ? 1 : 0
  source                       = "./modules/rds"
  project_name                 = var.project_name
  environment                  = var.environment
  region                       = var.region
  vpc_id                       = module.vpc[0].vpc_id

  eks_sg_id                    = local.eks_exists ? module.eks[0].node_security_group_id : null
  bastion_sg_id                = local.bastion_exists ? module.bastion[0].bastion_sg_id : null

  rds_engine_version           = var.rds_engine_version
  rds_instance_allocated_storage = var.rds_instance_allocated_storage
  rds_port                     = var.rds_port
  rds_db_instance_class        = var.rds_db_instance_class
  rds_db_default_name          = var.rds_db_default_name
  rds_engine                   = var.rds_engine
  rds_master_credentials_user  = var.rds_master_credentials_user

  subnet_ids                   = module.vpc[0].private_subnets
  public_subnets_cidr_blocks   = module.vpc[0].public_subnets_cidr_blocks

  depends_on                   = [ module.vpc ]
}