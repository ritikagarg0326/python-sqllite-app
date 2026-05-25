resource "aws_ecr_repository" "flask_repo" {

  name                 = "flask-app"

  image_tag_mutability = "MUTABLE"

  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "flask-app-ecr"
    Environment = "dev"
    Terraform   = "true"
  }
}