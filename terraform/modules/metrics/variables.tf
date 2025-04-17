variable project_name {
    description = "Project name"
    type        = string
}

variable environment {
    description = "Environment name"
    type        = string
}

variable eks_metrics_server_version {
    description = "Version of the metrics server Helm chart"
    type        = string
}