variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "environment" { type = string }
variable "cidr_bastion_access" { type = list(string) }