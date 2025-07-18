resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-repo"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
