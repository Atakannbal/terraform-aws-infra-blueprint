# VPC module to create a VPC for the EKS cluster and RDS
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "${var.project_name}-${var.environment}-vpc"
  cidr               = var.vpc_cidr_range
  azs                = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets

  # Enable a NAT Gateway for private subnets to access the internet
  enable_nat_gateway = true
  # Use a single NAT Gateway to reduce costs
  single_nat_gateway = true
  # Automatically assign public IPs to instances in public subnets
  map_public_ip_on_launch = true
  
  # Tags for Kubernetes to identify the VPC
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  # Tags for public subnets to allow ALB creation
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # Tags for private subnets to allow internal load balancers
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

 
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints (ECR/STS)"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_vpc_to_vpc_endpoints" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_endpoints.id
  cidr_blocks       = [var.vpc_cidr_range]
  description       = "Allow all VPC traffic to VPC endpoints on 443 (for testing)"
}

