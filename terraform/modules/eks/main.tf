# IAM role for the EKS node group
resource "aws_iam_role" "eks_node_group_role" {
  name = "ce-task-eks-node-group-role"

  # Allow EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy to allow nodes to pull images from ECR
resource "aws_iam_role_policy_attachment" "eks_node_ecr_readonly" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Policy to allow nodes to function as EKS workers
resource "aws_iam_role_policy_attachment" "eks_node_group_worker_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Policy to allow nodes to manage VPC CNI (networking)
resource "aws_iam_role_policy_attachment" "eks_node_group_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# EKS module to create the Kubernetes cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.14.0"
  

  cluster_name    = var.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id          = var.vpc_id

  # Place EKS nodes in private subnets for security
  subnet_ids      = var.subnet_ids

  # Explicityle disable node group creation in the module
  eks_managed_node_groups = {}
  
  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  
  # Allow public access to the cluster endpoint (restricted by CIDR)
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cidr_external_access
  # Allow private access to the cluster endpoint
  cluster_endpoint_private_access      = true
  # Enable IRSA for service accounts (e.g., AWS Load Balancer Controller, External DNS)
  enable_irsa                          = true
  # Grant admin permissions to the cluster creator
  enable_cluster_creator_admin_permissions = true
}

resource "aws_eks_node_group" "default" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${var.cluster_name}-default-ng"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 15
    min_size     = 2
  }

  instance_types = var.eks_instance_type

  # Ensure the node group is created after the cluster and VPC CNI addon
  depends_on = [
    module.eks.cluster_id,
    module.eks.cluster_addons
  ]

  tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}