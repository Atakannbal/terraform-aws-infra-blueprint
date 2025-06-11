data "aws_eks_cluster_auth" "this" {
  count = local.eks_exists ? 1 : 0
  name = local.eks_exists ? module.eks[0].cluster_name : ""
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "codebuild" {
  count = var.enable_codebuild_module ? 1 : 0
  name  = "github_pat"
}

data "aws_secretsmanager_secret_version" "codebuild_version" {
  count     = var.enable_codebuild_module ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.codebuild[0].id
}