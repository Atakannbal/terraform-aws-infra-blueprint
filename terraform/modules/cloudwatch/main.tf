resource "aws_eks_addon" "pod_identity" {
  cluster_name  = var.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.eks_addon_podIdentity_version
}

resource "aws_iam_role" "cloudwatch_observability" {
  name = "${var.project_name}-${var.environment}-cloudwatch-observability-role"

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

resource "aws_iam_role_policy" "cloudwatch_observability_permissions" {
  name   = "${var.project_name}-${var.environment}-cloudwatch-observability-permissions"
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

resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = var.cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/eks/${var.project_name}-${var.environment}/frontend"
  retention_in_days = 7
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/eks/${var.project_name}-${var.environment}/backend"
  retention_in_days = 7
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eks_addon" "cloudwatch_container_insights" {
  cluster_name = var.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  addon_version = var.eks_addon_cloudwatchContainerInsights_version  # Minimum version supporting EKS Pod Identity (3.1.0 or later)

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
                cluster_name = var.cluster_name
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
                cluster_name = var.cluster_name
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
    aws_eks_addon.pod_identity,
    aws_eks_pod_identity_association.cloudwatch_observability,
    aws_cloudwatch_log_group.container_insights_performance
  ]
}

resource "aws_cloudwatch_log_group" "container_insights_performance" {
  name              = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = 7
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

