output "aws_load_balancer_controller" {
    description = "Helm release for the AWS Load Balancer Controller"
    value       = helm_release.aws_load_balancer_controller
}