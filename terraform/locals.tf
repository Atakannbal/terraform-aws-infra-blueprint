# Local variables for reusable values across the configuration
locals {
  eks_exists      = length(module.eks) > 0
  rds_exists      = length(module.rds) > 0
  bastion_exists  = length(module.bastion) > 0
  ext_dns_exists  = length(module.ext-dns) > 0
  cloudfront_exists  = length(module.cloudfront) > 0

  cluster_name = "${var.project_name}-${var.environment}-eks-cluster"

  db_vars = {
    username           = try(module.rds[0].db_instance_username, null)
    password           = try(jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version[0].secret_string).password, null)
    db_url_with_prefix = try("jdbc:postgresql://${module.rds[0].db_instance_endpoint}/${module.rds[0].db_instance_name}", null)
  }

  frontend_image = "${module.ecr[0].frontend_repository_url}:v0.0.4-alpha"
  backend_image  = "${module.ecr[0].backend_repository_url}:v0.0.4-alpha"
}
