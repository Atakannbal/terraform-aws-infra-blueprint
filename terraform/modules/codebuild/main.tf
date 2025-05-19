resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_pat
}

# CodeBuild Project
resource "aws_codebuild_project" "eks_deploy" {
  name          = "${var.project_name}-${var.environment}-codebuild"
  description   = "Run GitHub Actions jobs to deploy to EKS"
  service_role  = aws_iam_role.codebuild_role.arn
  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }
  }
  source {
    type            = "GITHUB"
    location        = var.github_repo
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.codebuild_sg.id]
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
}

# Security Group for CodeBuild
resource "aws_security_group" "codebuild_sg" {
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-codebuild-sg"
  }
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildEKSDeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for CodeBuild
resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "s3:*",
          "ecr:*",
          "logs:*",
          "ssm:GetParameters",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DescribeRouteTables",             
          "ec2:DescribeAvailabilityZones" 
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })
}

# EKS Security Group Rule
resource "aws_security_group_rule" "eks_api_codebuild" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.eks_cluster_security_group_id
  source_security_group_id = aws_security_group.codebuild_sg.id
}

# Webhook for GitHub Actions
resource "aws_codebuild_webhook" "github" {
  project_name = aws_codebuild_project.eks_deploy.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

# Webhook Secret
resource "aws_ssm_parameter" "webhook_secret" {
  name  = "/codebuild/webhook-secret"
  type  = "SecureString"
  value = var.webhook_secret
}

# IAM Policy for SSM Access
resource "aws_iam_role_policy" "codebuild_ssm" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"]
      Resource = aws_ssm_parameter.webhook_secret.arn
    }]
  })
}