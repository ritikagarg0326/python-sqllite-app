resource "aws_ecr_repository" "flask_repo" {
  name = "flask-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}