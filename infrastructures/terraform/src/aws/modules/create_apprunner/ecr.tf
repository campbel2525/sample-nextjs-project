resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true


  encryption_configuration {
    encryption_type = "AES256"
  }
}
