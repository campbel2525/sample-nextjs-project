# output "apprunner_service_url" {
#   value = aws_apprunner_service.this.service_url
# }

# output "apprunner_service_id" {
#   value = aws_apprunner_service.this.id
# }

output "apprunner_service_arn" {
  value = aws_apprunner_service.this.arn
}

output "apprunner_service_url" {
  value = aws_apprunner_service.this.service_url
}

# output "ecr_arn" {
#   value = aws_ecr_repository.app.arn
# }

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.app.name
}
