
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
    value = var.secrets_dbUser
  }
  set {
    name  = "secrets.dbPassword"
    value = var.secrets_dbPassword
  }
  set {
    name  = "secrets.dbUrl"
    value = var.secrets_dbUrl
  }

  # Frontend image URL
  set {
    name  = "frontend.image"
    value = var.frontend_image
  }

  # Backend image URL
  set {
    name  = "backend.image"
    value = var.backend_image
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