#########################
### General variables ###
#########################
project_name = ""
environment = ""
region = ""
availability_zones = []

hosted_zone_domain_name = ""
load_balancer_domain_name = ""
cloudfront_domain_name = ""

##############################
### Enable/Disable modules ###
##############################

# Core infrastructure
enable_vpc_module = false
enable_ecr_module = false

# EKS and core cluster (require VPC)
enable_eks_module = false

# Cluster add-ons (require EKS)
enable_cluster_autoscaler_module = false
enable_external_dns_module = false
enable_alb_module = false
enable_external_secrets_module = false
enable_cloudwatch_module = false
enable_metrics_server_module = false
enable_hpa_module = false

# Data and build (require VPC, EKS for some)
enable_rds_module = false
enable_codebuild_module = false
enable_sns_module = false

# Application layer (require EKS, ECR, RDS, etc.)
enable_app_module = false
enable_bastion_module = false
enable_cloudfront_module = false

###########
### VPC ###
###########
vpc_cidr_range = ""
private_subnets = []
public_subnets = []

###########
### EKS ###
###########
eks_cluster_version = ""
eks_instance_type = []
eks_nodes_count = 0
eks_min_nodes_count = 0
eks_max_nodes_count = 0

###########
### APP ###
###########
backend_tag = ""
frontend_tag = ""

###########
### SG ####
###########
cidr_external_access = []
cidr_bastion_access = []

###################
### Helm charts ###
###################
alb_controller_version = ""
eks_external_dns_version = ""
eks_metrics_server_version = ""
eks_cluster_autoscaler_version = ""
external_secrets_helm_version = ""

###############
### Add-ons ###
###############
eks_addon_pod_identity_version = ""
eks_addon_cloudwatch_containerinsights_version = ""

###########
### RDS ###
###########
rds_engine = ""
rds_engine_version = ""
rds_db_instance_class = ""
rds_instance_allocated_storage = 0
rds_port = 0
rds_db_default_name = ""
rds_master_credentials_user = ""

#############
### SNS #####
#############
sns_subscriber_email_address = ""

##################
### CODEBUILD ####
##################
webhook_secret = ""
github_pat = ""
codebuild_compute_type = ""
codebuild_image = ""
codebuild_github_repo = ""