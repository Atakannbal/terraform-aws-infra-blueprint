module "bastion" {
  count = var.enable_ec2_bastion_module ? 1 : 0
  source       = "./modules/bastion"
  project_name = var.project_name
  environment = var.environment

  vpc_id       = module.vpc[0].vpc_id
  subnet_id    = module.vpc[0].public_subnets[0]
  cidr_bastion_access = var.cidr_bastion_access
}