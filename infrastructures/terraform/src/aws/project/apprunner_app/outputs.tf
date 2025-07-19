output "created_ecr_repository_name" {
  description = "The name of the ECR repository created by the module."
  value       = module.user_front_apprunner.ecr_repository_name
}
output "app_runner_url" {
  description = "The URL of the App Runner service."
  value       = module.user_front_apprunner.apprunner_service_url
}
