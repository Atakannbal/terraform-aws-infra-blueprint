output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_credentials_secret_name" {
  value = aws_secretsmanager_secret.db_credentials.name
}

output "db_credentials_secret_version" {
  value = aws_secretsmanager_secret_version.db_credentials_version.secret_string
}

output "db_instance_identifier" {
  description = "Identifier of the RDS database instance"
  value       = module.rds.db_instance_identifier
}
