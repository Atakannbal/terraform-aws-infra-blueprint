###################################################################################
# This module provisions two AWS ECR repositories (backend and frontend) 
# for storing Docker images used by the application. Each repository is named 
# using the project and environment variables for clear separation and management.

# image_tag_mutability controls whether image tags can be overwritten (MUTABLE) or are immutable (IMMUTABLE)
# force_delete allows repository deletion even if images exist (use with caution)
###################################################################################

resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}-${var.environment}-backend-ecr"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  tags = {
    Name = "${var.project_name}-${var.environment}-backend-ecr"
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-${var.environment}-frontend-ecr"

  image_tag_mutability = var.image_tag_mutability
  
  force_delete         = var.force_delete
  tags = {
    Name = "${var.project_name}-${var.environment}-frontend-ecr"
  }
}