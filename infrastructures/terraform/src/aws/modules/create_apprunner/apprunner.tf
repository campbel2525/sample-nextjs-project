resource "aws_apprunner_vpc_connector" "example" {
  count = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0 ? 1 : 0

  vpc_connector_name = "${var.app_name}-vpc-connector"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
}

resource "aws_apprunner_service" "example" {
  service_name = "${var.app_name}-apprunner-service"

  source_configuration {
    auto_deployments_enabled = true

    # 認証設定を追記
    authentication_configuration {
      connection_arn = var.apprunner_connection_arn
    }

    code_repository {
      repository_url = var.github_repository_url
      source_code_version {
        type  = "BRANCH"
        value = var.github_branch_name
      }
      code_configuration {
        configuration_source = "REPOSITORY"
      }
    }
  }

  instance_configuration {
    cpu               = var.apprunner_cpu
    memory            = var.apprunner_memory
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = try(aws_apprunner_vpc_connector.example[0].arn, null)
    }
  }
}
