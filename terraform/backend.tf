terraform {
  backend "s3" {
    bucket = "ce-project-aws-terraform-state-prod"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}