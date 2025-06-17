output "codebuild_role_arn" {
  description = "IAM role ARN for CodeBuild project"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_sg_id" {
  description = "Security group ID for codebuild"
  value = aws_security_group.codebuild_sg.id
}