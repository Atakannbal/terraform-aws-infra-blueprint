############################################################################
# This module provisions the Kubernetes Metrics Server via Helm for EKS.
# Enables resource usage metrics collection for autoscaling and monitoring.
#############################################################################

resource "helm_release" "metrics_server" {
  name       = "${var.project_name}-${var.environment}-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.eks_metrics_server_version
  upgrade_install = true

  set {
    name  = "resources.requests.cpu"
    value = "50m"
  }
  set {
    name  = "resources.requests.memory"
    value = "64Mi"
  }
  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }
  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }
}