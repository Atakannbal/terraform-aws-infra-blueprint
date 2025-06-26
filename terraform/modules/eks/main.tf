#########################################################################
# This block sets up a production EKS cluster with self-managed,        #
# autoscaling node group, secure networking and                         #
# all the features needed for modern AWS/Kubernetes best practices.     #
#                                                                       #
# Places the cluster in specified VPC and subnets.                      #
# Creates a custom autoscaling node group.                              #
# Installs and configures the VPC CNI networking add-on.                #
# Enables both public and private API access, with CIDR restrictions.   #
# Enable IAM Roles for service accounts (secure AWS access for pods).   #
# Grants admin rights to the cluster creator.                           #
# Uses both API and ConfigMap for authentication.                       #
#########################################################################

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.14.0"  

  cluster_name    = var.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  
  authentication_mode = "API_AND_CONFIG_MAP"

  cluster_additional_security_group_ids = [var.vpc_endpoints_sg_id]
  
  access_entries = {
    codebuild = {
      kubernetes_groups = ["codebuild-deployers"]
      principal_arn     = var.codebuild_role_arn
      policy_associations = {
        deploy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {}
  self_managed_node_groups = {
    example = {
      ami_type      = "AL2_x86_64"
      instance_type = var.eks_instance_type[0]
      
      min_size     = var.eks_min_nodes_count
      max_size     = var.eks_max_nodes_count
      desired_size = var.eks_nodes_count

      key_name = "my-eks-key"
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=8'"

      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }  
  }
  
  cluster_addons = {
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
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
  
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cidr_external_access
  cluster_endpoint_private_access      = true
  enable_irsa                          = true
  enable_cluster_creator_admin_permissions = true
}


##############################################################################################################
# Following resources create an IAM role for EKS worker nodes and attach the necessarry AWS managed policies #
# so nodes can join the cluster, pull images from ECR, and manage VPC networking.                            #
##############################################################################################################

resource "aws_iam_role" "eks_node_group_role" {
  name = "ce-task-eks-node-group-role"
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

resource "aws_iam_role_policy_attachment" "eks_node_ecr_readonly" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_worker_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


########################################################################################
# Deploys RBAC resources for CodeBuild deployments via Helm. This Helm release applies #
# only the ClusterRole and ClusterRoleBinding needed for CodeBuild to deploy to EKS,   #
# using least-privilege permissions and group-based access (codebuild-deployers).      #
########################################################################################


resource "helm_release" "codebuild_rbac" {
  name       = "codebuild-rbac"
  chart      = "${path.module}/helm"
  namespace  = "kube-system"
  depends_on = [ module.eks ]

  lifecycle {
    prevent_destroy = true
  }
}