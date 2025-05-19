data "aws_eks_cluster_auth" "this" {
  count = local.eks_exists ? 1 : 0
  name = local.eks_exists ? module.eks[0].cluster_name : ""
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "rds_secret" {
  count = local.rds_exists ? 1 : 0
  arn   = module.rds[0].db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  count     = local.rds_exists ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.rds_secret[0].id
}
