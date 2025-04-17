variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_sg_id" { type = string }
variable "bastion_sg_id" { type = string }
variable "public_subnets_cidr_blocks" {type = list(string)}