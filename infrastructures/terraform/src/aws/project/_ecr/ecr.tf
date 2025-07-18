resource "aws_ecr_repository" "app" {
  name                 = "user-front-repo"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
