# Create an ECR repository for the backend
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  tags = {
    Name = "${var.project_name}-backend-ecr"
  }
}

# Create an ECR repository for the frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  tags = {
    Name = "${var.project_name}-frontend-ecr"
  }
}