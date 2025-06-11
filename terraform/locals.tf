# Local variables for reusable values across the configuration
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks-cluster"
  eks_exists         = length(module.eks) > 0
  ecr_exists         = length(module.ecr) > 0
  rds_exists         = length(module.rds) > 0
  bastion_exists     = length(module.bastion) > 0
  ext_dns_exists     = length(module.ext-dns) > 0
  cloudfront_exists  = length(module.cloudfront) > 0
  route53_exists     = length(module.route53) > 0
}
