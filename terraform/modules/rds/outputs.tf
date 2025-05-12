output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_instance_master_user_secret_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}

output "db_instance_username" {
  value = module.rds.db_instance_username
}

output "db_instance_name" {
  value = module.rds.db_instance_name
}

output "db_instance_identifier" {
  description = "Identifier of the RDS database instance"
  value       = module.rds.db_instance_identifier
}
