# SSMパラメータの「入れ物」を定義
resource "aws_ssm_parameter" "app_env" {
  name  = "/amplify/${var.app_name}/.env"
  type  = "SecureString"
  value = "default value"

  lifecycle {
    ignore_changes = [value]
  }
}
