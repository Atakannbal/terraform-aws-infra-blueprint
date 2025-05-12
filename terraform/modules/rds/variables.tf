variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_sg_id" { 
    type = string
    default = null 
}
variable "bastion_sg_id" { 
    type = string 
    default = null 
}
variable "public_subnets_cidr_blocks" {type = list(string)}
variable "environment" { type = string }
variable "rds_engine" { type = string }
variable "rds_engine_version" { type = string }
variable "rds_db_instance_class" { type = string }
variable "rds_db_default_name" { type = string }
variable "rds_instance_allocated_storage" { type = number }
variable "rds_port" { type = number }
variable "rds_master_credentials_user" { type = string }
