
# 環境変数のためのssm
locals {
  app_env_vars = {
    "SECRET_KEY" = {
      type  = "SecureString"
      value = "default value"
    }
    "FRONTEND_API_URL" = {
      type  = "SecureString"
      value = "default value"
    }
    "DATABASE_URL" = {
      type  = "SecureString"
      value = "default value"
    }
    "NEXTAUTH_URL" = {
      type  = "SecureString"
      value = "default value"
    }
    "NEXTAUTH_SECRET" = {
      type  = "SecureString"
      value = "default value"
    }
  }
}

# for_each を使って、localsで定義したマップの各要素に対してSSMパラメータリソースを作成します。
resource "aws_ssm_parameter" "app_env_vars" {
  for_each = local.app_env_vars

  name  = "/apprunner/user-front/env/${each.key}"
  type  = each.value.type
  value = each.value.value

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_apprunner_connection" "github" {
  connection_name = "github-connection"
  provider_type   = "GITHUB"
}

module "user_front" {
  source = "../../modules/create_apprunner"

  app_name              = "user-front"
  github_repository_url = var.github_repository_url
  github_branch_name    = var.github_branch_name
  apprunner_cpu         = 256
  apprunner_memory      = 512
  subnet_ids = [
    module.private_subnet_1a.id,
    module.private_subnet_1c.id,
  ]
  security_group_ids              = [module.app_sg.id]
  apprunner_connection_github_arn = aws_apprunner_connection.github.arn
  ssm_parameter_arns              = values(aws_ssm_parameter.app_env_vars)[*].arn
}
