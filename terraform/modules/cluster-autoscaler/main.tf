#############################################################################################
# This module provisions all resources required for Kubernetes Cluster Autoscaler on EKS.
# Includes IAM policy, IAM role with IRSA, service account, and Helm deployment.
# Ensures secure, automated node scaling for your EKS cluster.
#############################################################################################

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.eks_cluster_autoscaler_version

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "image.tag"
    value = "v1.31.0"
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = "false"  # Prevent Helm from creating a service account
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }
  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }
  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }
  set {
    name  = "extraArgs.logtostderr"
    value = "true"
  }
  set {
    name  = "extraArgs.stderrthreshold"
    value = "info"
  }
  set {
    name  = "extraArgs.v"
    value = "2"
  }
  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "2m"
  }
  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "2m"
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.cluster_name}-ClusterAutoscalerPolicy"
  description = "Policy for EKS Cluster Autoscaler"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-ClusterAutoscalerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}