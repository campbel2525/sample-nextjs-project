# resource "aws_ssm_parameter" "app_env_vars" {
#   name  = "/apprunner/${var.app_name}/env_vars"
#   type  = "SecureString"
#   value = "{}"

#   lifecycle {
#     ignore_changes = [value]
#   }
# }
