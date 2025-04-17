variable "my_ip" {
  description = "My public IP adress for SSH and database access"
  type = string
}

variable "iam_user_arn" {
  description = "ARN of the IAM user running Terraform"
  type        = string
}

variable "iam_user_name" {
  description = "Name of the IAM user running Terraform"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ExternalDNS"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}