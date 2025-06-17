####################################################################################################
# Local variables and random integer resource for reusable values across the configuration.
# The random integer is used to help ensure unique EKS cluster names and avoid naming conflicts.
# Shorter postfix (3 digits) is used to help keep resource names within AWS length limits.
####################################################################################################

resource "random_integer" "eks_postfix" {
  min = 100
  max = 999
}

locals {
  cluster_name = "${var.project_name}-${var.environment}-eks-cluster-${random_integer.eks_postfix.result}"
  eks_exists         = length(module.eks) > 0
  ecr_exists         = length(module.ecr) > 0
  rds_exists         = length(module.rds) > 0
  bastion_exists     = length(module.bastion) > 0
  ext_dns_exists     = length(module.ext-dns) > 0
  cloudfront_exists  = length(module.cloudfront) > 0
  route53_exists     = length(module.route53) > 0
  codebuild_exists   = length(module.codebuild) > 0
}
