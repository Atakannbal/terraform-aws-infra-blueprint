###################################################################################################
# This module provisions Horizontal Pod Autoscalers (HPA) for backend and frontend deployments.
# Enables dynamic scaling of pods based on CPU and memory utilization in EKS.
###################################################################################################

resource "kubernetes_horizontal_pod_autoscaler_v2" "backend_hpa" {
  metadata {
    name      = "${var.project_name}-${var.environment}-backend-hpa"
    namespace = "default"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "backend" 
    }
    min_replicas = 1
    max_replicas = 2
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 90
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 65
        }
      }
    }
    behavior {
      scale_up {
        stabilization_window_seconds = 10
        select_policy = "Max"

        policy {
          type = "Percent"
          value = 50
          period_seconds = 5
        }
      }
      scale_down {
        stabilization_window_seconds = 60
        select_policy = "Max"

        policy {
          type = "Percent"
          value = 50
          period_seconds = 5
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "frontend_hpa" {
  metadata {
    name      = "${var.project_name}-${var.environment}-frontend-hpa"
    namespace = "default"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "frontend" 
    }
    min_replicas = 1
    max_replicas = 2
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 5
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 5
        }
      }
    }
  }
}