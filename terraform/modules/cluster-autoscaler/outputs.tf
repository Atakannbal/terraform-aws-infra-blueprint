output "cluster_autoscaler_role_arn" {
  description = "ARN of the IAM role for the Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "cluster_autoscaler_policy_arn" {
  description = "ARN of the IAM policy for the Cluster Autoscaler"
  value       = aws_iam_policy.cluster_autoscaler.arn
}