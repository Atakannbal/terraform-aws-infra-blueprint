# Local variables for reusable values across the configuration
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks-cluster"
  db_secrets = length(module.rds) > 0 ? jsondecode(module.rds[0].db_credentials_secret_version) : null
  db_url_with_prefix = length(module.rds) > 0 ? "jdbc:postgresql://${local.db_secrets.host}/${local.db_secrets.dbname}" : null
  frontend_image = "${module.ecr[0].frontend_repository_url}:v0.0.4-alpha"
  backend_image  = "${module.ecr[0].backend_repository_url}:v0.0.4-alpha"
}
