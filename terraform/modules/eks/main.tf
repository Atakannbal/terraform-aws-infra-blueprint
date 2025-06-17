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

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI account ID

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v*"]
  }
}

resource "aws_launch_template" "self_ng" {
  name_prefix   = "${var.cluster_name}-self-ng-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = var.eks_instance_type[0]
  user_data     = base64encode(templatefile("${path.module}/userdata.tpl", {
    cluster_name    = var.cluster_name
    cluster_endpoint = module.eks.cluster_endpoint
    certificate_authority_data  = module.eks.cluster_certificate_authority_data
  }))
}

resource "aws_autoscaling_group" "self_ng" {
  desired_capacity     = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.self_ng.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = "arn:aws:iam::980921750296:role/ce-task-eks-node-group-role"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
  }
}


/*

resource "aws_launch_template" "eks_ng" {
  name = "${var.cluster_name}-ng-launch-template"
  image_id      = null # Use EKS default AMI
  instance_type = var.eks_instance_type[0]
  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    cluster_name    = var.cluster_name
    cluster_endpoint = module.eks.cluster_endpoint
    certificate_authority_data  = module.eks.cluster_certificate_authority_data
  }))
}

resource "aws_eks_node_group" "default" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${var.cluster_name}-default-ng"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.eks_nodes_count
    max_size     = var.eks_max_nodes_count
    min_size     = var.eks_min_nodes_count
  }


  launch_template {
    id      = aws_launch_template.eks_ng.id
    version = "$Latest"
  }

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
*/
