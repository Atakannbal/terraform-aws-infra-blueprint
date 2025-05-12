
# Data source to retrieve the ACM certificate for the frontend domain
data "aws_acm_certificate" "frontend" {
  domain   = var.frontend_hostname
  statuses = ["ISSUED"]
  most_recent = true
}

# Helm release for the application (frontend and backend)
resource "helm_release" "app" {
  name       = "app"
  chart      = "${path.module}/helm"
  namespace  = "default"

  # Database credentials for the backend
  set {
    name  = "secrets.dbUser"
    value = var.db_user
  }
  set {
    name  = "secrets.dbPassword"
    value = var.db_password
  }
  set {
    name  = "secrets.dbUrl"
    value = var.db_url
  }

  # Frontend image URL
  set {
    name  = "frontend.image"
    value = var.frontend_image_url
  }

  # Backend image URL
  set {
    name  = "backend.image"
    value = var.backend_image_url
  }

  # Hostname for the frontend Ingress
  set {
    name  = "frontend.hostname"
    value = var.frontend_hostname
  }

  # ACM certificate ARN for HTTPS
  set {
    name  = "frontend.certArn"
    value = data.aws_acm_certificate.frontend.arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "projectName"
    value = var.projectName
  }
}