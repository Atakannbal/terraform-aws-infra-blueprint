# Data source to get the current A WS account ID
data "aws_caller_identity" "current" {}

# Data source to get EKS cluster authentication token
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Data source to retrieve the ACM certificate for the frontend domain
data "aws_acm_certificate" "frontend" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

# VPC module to create a VPC for the EKS cluster and RDS
module "vpc" {
  source             = "./modules/vpc"
  cluster_name = local.cluster_name
  project_name = local.project_name
  region = var.region


}

# ECR module to create repositories for frontend and backend images
module "ecr" {
  source       = "./modules/ecr"
  project_name = local.project_name
}

# Bastion module to create a bastion host for secure access to RDS
module "bastion" {
  source       = "./modules/bastion"
  project_name = local.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnets[0]
  my_ip        = var.my_ip
}

# EKS module to create the Kubernetes cluster
module "eks" {
  source          = "./modules/eks"
  
  cluster_name = local.cluster_name
  my_ip = var.my_ip
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}

module "rds" {
  source         = "./modules/rds"
  project_name   = local.project_name
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
  public_subnets_cidr_blocks = module.vpc.public_subnets_cidr_blocks

  # Security group for EKS nodes to access RDS
  eks_sg_id      = module.eks.node_security_group_id  

  # Security group for the bastion host to access RDS
  bastion_sg_id  = module.bastion.bastion_sg_id
}

module "ext-dns" {
  source = "./modules/ext-dns"
  depends_on = [module.eks]

  account_id = data.aws_caller_identity.current.account_id
  oidc_provider = module.eks.oidc_provider
  domain_name = var.domain_name
  cluster_name = local.cluster_name
  vpc_id = module.vpc.vpc_id
  region = var.region
}

module "alb" {
  source = "./modules/alb"
  depends_on = [module.eks, module.eks.eks_managed_node_groups]

  project_name = local.project_name
  oidc_provider = module.eks.oidc_provider
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  cluster_name = local.cluster_name
}

# Helm release for the application (frontend and backend)
resource "helm_release" "app" {
  name       = "app"
  chart      = "../k8s/charts/app"
  namespace  = "default"
  depends_on = [module.eks, module.alb.aws_load_balancer_controller, module.ext-dns.external_dns]

  # Database credentials for the backend
  set {
    name  = "secrets.dbUser"
    value = local.db_secrets.username
  }
  set {
    name  = "secrets.dbPassword"
    value = local.db_secrets.password
  }
  set {
    name  = "secrets.dbUrl"
    value = local.db_url_with_prefix
  }

  # Frontend image URL
  set {
    name  = "frontend.image"
    value = local.frontend_image
  }

  # Backend image URL
  set {
    name  = "backend.image"
    value = local.backend_image
  }

  # Hostname for the frontend Ingress
  set {
    name  = "frontend.hostname"
    value = var.domain_name
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
    value = local.project_name
  }
}

# Horizontal Pod Autoscaler for backend and frontend deployments


resource "kubernetes_horizontal_pod_autoscaler_v2" "backend_hpa" {
  metadata {
    name      = "backend-hpa"
    namespace = "default"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "backend"  # Dynamically construct the name
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
        select_policy = "Max" # Use the policy with the largest scaling change

        policy {
          type = "Percent"
          value = 50
          period_seconds = 5
        }
      }
      scale_down {
        stabilization_window_seconds = 60
        select_policy = "Max" # Use the policy with the largest scaling change

        policy {
          type = "Percent"
          value = 50
          period_seconds = 5
        }
      }
    }
  }
  depends_on = [helm_release.app]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "frontend_hpa" {
  metadata {
    name      = "frontend-hpa"
    namespace = "default"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "frontend"  # Dynamically construct the name
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
  depends_on = [helm_release.app]
}

# Helm release for Kubernetes Metrics Server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1" 

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

  depends_on = [module.eks, module.eks.eks_managed_node_groups]
}

# CloudWatch

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.0.0-eksbuild.1"  # Use the latest version compatible with your cluster

  depends_on = [module.eks]
}

resource "aws_iam_role" "cloudwatch_observability" {
  name = "${local.project_name}-cloudwatch-observability-role"

  # Minimum trust policy for EKS Pod Identity
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = module.eks.cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn

  depends_on = [module.eks]
}


resource "aws_iam_role_policy" "cloudwatch_observability_permissions" {
  name   = "${local.project_name}-cloudwatch-observability-permissions"
  role   = aws_iam_role.cloudwatch_observability.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", 
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*" 
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create CloudWatch Log Group for frontend
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/eks/${local.project_name}/frontend"
  retention_in_days = 7  # Retain logs for 7 days
  tags = {
    Environment = "production"
    Project     = local.project_name
  }
}

# Create CloudWatch Log Group for backend
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/eks/${local.project_name}/backend"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Project     = local.project_name
  }
}



resource "aws_eks_addon" "cloudwatch_container_insights" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  addon_version = "v3.6.0-eksbuild.2"  # Minimum version supporting EKS Pod Identity (3.1.0 or later)

  configuration_values = jsonencode({
      agent = {
        resources = {
          requests = {
            cpu    = "30m"
            memory = "50Mi"
          }
          limits = {
            cpu    = "60m"
            memory = "100Mi"
          }
        }
        config = {
          metrics = {
            metrics_collected = {
              kubernetes = {
                cluster_name = local.cluster_name
                metrics_collection_interval = 60
                measurement = [
                  "pod_cpu_utilization",
                  "pod_memory_utilization"
                ]
                namespace_filter = {
                  include = ["default"]
                }
              }
            }
          }
          logs = {
            metrics_collected = {
              kubernetes = {
                cluster_name = local.cluster_name
                namespace_filter = {
                  include = ["default"]
                }
              }
            }
          }
        }
      }
  })


  depends_on = [
    module.eks,
    aws_eks_addon.pod_identity,
    aws_eks_pod_identity_association.cloudwatch_observability,
    module.alb.aws_load_balancer_controller,
    aws_cloudwatch_log_group.container_insights_performance
  ]
}

resource "aws_cloudwatch_log_group" "container_insights_performance" {
  name              = "/aws/containerinsights/${module.eks.cluster_name}/performance"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Project     = local.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_high_cpu" {
  alarm_name          = "${local.project_name}-frontend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Frontend Pods CPU usage is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.eks.cluster_name # This should be correct
    Namespace   = "default"
    Podname     = "frontend"
  }
}

# SNS Topic for notifications
resource "aws_sns_topic" "alerts" {
  name = "${local.project_name}-alerts"
}

# SNS Topic Subscription (replace with your email)
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "atakannbal@gmail.com"  # Replace with your email
}

resource "aws_cloudwatch_metric_alarm" "backend_high_cpu" {
  alarm_name          = "${local.project_name}-backend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "Backend Pods CPU usage is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.eks.cluster_name
    Namespace   = "default"
    PodName     = "backend"
  }
}





