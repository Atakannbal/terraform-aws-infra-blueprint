# Local variables for reusable values across the configuration
locals {
  project_name = "ce-task"
  cluster_name = "${local.project_name}-eks-cluster"

  # Contains username, password, host, and dbname
  db_secrets = jsondecode(module.rds.db_credentials_secret_version)

  # Construct the JDBC URL for the PostgreSQL database
  db_url_with_prefix = "jdbc:postgresql://${local.db_secrets.host}/${local.db_secrets.dbname}"
  
  # Docker image URLs for the frontend and backend applications
  frontend_image = "${module.ecr.frontend_repository_url}:v0.0.4-alpha"
  backend_image  = "${module.ecr.backend_repository_url}:v0.0.4-alpha"
}
