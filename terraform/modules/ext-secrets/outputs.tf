output "service_account_name" {
  value = kubernetes_service_account.external_secrets.metadata[0].name
}

output "service_account_namespace" {
  value = kubernetes_service_account.external_secrets.metadata[0].namespace
}

output "iam_role_arn" {
  value = aws_iam_role.external_secrets.arn
}
