# VPC module to create a VPC for the EKS cluster and RDS
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "${var.project_name}-${var.environment}-vpc"
  cidr               = "10.0.0.0/16"
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
