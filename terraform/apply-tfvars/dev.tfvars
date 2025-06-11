#########################
### General variables ###
#########################
project_name = "ce-task"
environment = "dev"
region = "eu-central-1"
availability_zones = ["eu-central-1a"]

hosted_zone_domain_name = "ce-project-aws.atakanbal.com"
load_balancer_domain_name = "internal-dev.ce-project-aws.atakanbal.com"
cloudfront_domain_name = "dev.ce-project-aws.atakanbal.com"

##############################
### Enable/Disable modules ###
##############################

# Core infrastructure
enable_vpc_module = false
enable_ecr_module = true

# EKS and core cluster (require VPC)
enable_eks_module = false

# Cluster add-ons (require EKS)
enable_cluster_autoscaler_module = false
enable_external_dns_module = false
enable_alb_module = false
enable_external_secrets_module = false
enable_hpa_module = false
enable_cloudwatch_module = false
enable_metrics_server_module = false

# Data and build (require VPC, EKS for some)
enable_rds_module = false
enable_codebuild_module = false
enable_sns_module = false

# Application layer (require EKS, ECR, RDS, etc.)
enable_app_module = false
enable_bastion_module = false
enable_cloudfront_module = false

###########
### APP ###
###########
backend_tag = "latest"
frontend_tag = "latest"

###########
### VPC ###
###########
vpc_cidr_range = "10.0.0.0/16"
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

###########
### SG ####
###########
cidr_external_access = ["0.0.0.0/0"]
cidr_bastion_access = ["0.0.0.0/0"]

###########
### EKS ###
###########
eks_cluster_version = "1.31"
eks_instance_type = ["t3.micro"]
eks_nodes_count = 1
eks_min_nodes_count = 1
eks_max_nodes_count = 10

###################
### Helm charts ###
###################
alb_controller_version = "1.10.0"
eks_external_dns_version = "0.14.2"
eks_metrics_server_version = "3.12.1"
eks_cluster_autoscaler_version = "9.46.6"
external_secrets_helm_version = "0.17.0"

###############
### Add-ons ###
###############
eks_addon_pod_identity_version = "v1.0.0-eksbuild.1"
eks_addon_cloudwatch_containerinsights_version = "v3.6.0-eksbuild.2"

###########
### RDS ###
###########
rds_engine = "postgres"
rds_engine_version = "15"
rds_db_instance_class = "db.t3.micro"
rds_instance_allocated_storage = 20
rds_port = 5432
rds_db_default_name = "calculator"
rds_master_credentials_user = "atakbal"

#############
### SNS #####
#############
sns_subscriber_email_address = "atakannbal@gmail.com"

##################
### CODEBUILD ####
##################
codebuild_compute_type = "BUILD_GENERAL1_SMALL"
codebuild_image = "aws/codebuild/standard:7.0"
codebuild_github_repo = "https://github.com/Atakannbal/terraform-aws-infra-blueprint.git"


