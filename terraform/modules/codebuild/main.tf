/*######################################################################################
# Creates an AWS CodeBuild project for deploying applications to EKS                   #
# Uses a Github repository as the source and a custom buildspec for deployment steps.  #
# Runs in a VPC with specified subnets and security groups for secure access           #
# Enables Docker layer and source caching for faster builds.                           #
# Sends build logs to Cloudwatch for monitoring and troubleshooting.                   #
######################################################################################*/

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
  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}-${var.environment}-codebuild"
    }
  }
}

####################################
# Github webhook and access token  #
####################################

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

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_pat
}

######################################################################
# Allow all outbound traffic from CodeBuild jobs via VPC endpoints   #
# (enables private access to EKS, ECR, and STS from private subnets) #
######################################################################

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

/*
resource "aws_security_group_rule" "vpc_endpoints_from_codebuild" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.codebuild_sg.id
  source_security_group_id = aws_security_group.codebuild_sg.id
  description              = "Allow HTTPS from CodeBuild to all VPC interface endpoints"
}
*/





###################################################
# Handle AWS-level permissions                    #
###################################################
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
          "eks:AccessKubernetesApi",
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

# Webhook for GitHub Actions

#################
# TO BE DELETED #
#################

/* 

data "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}


resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        yamldecode(data.kubernetes_config_map_v1.aws_auth.data["mapRoles"]),
        [
          {
            rolearn  = "arn:aws:iam::980921750296:role/ce-task-eks-node-group-role"
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          },
          {
            rolearn  = aws_iam_role.codebuild_role.arn
            username = "codebuild"
            groups   = ["system:masters"]
          }
        ]
      ))
    )
  }
}
*/