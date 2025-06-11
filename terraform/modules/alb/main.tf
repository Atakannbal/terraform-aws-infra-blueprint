# IAM policy for the AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/aws-lb-controller-policy.json")
}

# IAM role for the AWS Load Balancer Controller using IRSA
module "aws_lb_controller_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "~> 5.0"
  create_role = true
  role_name   = "${var.project_name}-${var.environment}-aws-lb-controller-role"
  provider_url = var.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
  role_policy_arns = [aws_iam_policy.aws_lb_controller_policy.arn]
}

# Service account for the AWS Load Balancer Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_lb_controller_role.iam_role_arn
    }
  }
}

# Helm release for the AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_version
  depends_on = [kubernetes_service_account.aws_load_balancer_controller]
  upgrade_install = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${var.account_id}:role/${var.project_name}-aws-lb-controller-role"
  }

  set {
    name  = "image.tag"
    value = "v2.12.0"
  }

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "ingressClass"
    value = "alb"
  }

  set {
    name  = "region"
    value = var.region
  }

  wait    = true
  timeout = 600
}
