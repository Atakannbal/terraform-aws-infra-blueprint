variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_instance_type" { type = list(string) }
variable "eks_cluster_version"  { type = string }
variable "cidr_external_access" { type = list(string) }