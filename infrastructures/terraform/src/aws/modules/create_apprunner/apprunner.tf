resource "aws_apprunner_vpc_connector" "this" {
  count = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0 ? 1 : 0

  vpc_connector_name = "${var.app_name}-vpc-connector"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
}

resource "aws_apprunner_service" "this" {
  service_name = "${var.app_name}-apprunner-service"

  source_configuration {
    auto_deployments_enabled = var.apprunner_auto_deployments_enabled

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"

      image_configuration {
        port = var.apprunner_port
      }
    }
  }

  instance_configuration {
    cpu    = var.apprunner_cpu
    memory = var.apprunner_memory
    # 修正: 正しいロール名を参照
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = try(aws_apprunner_vpc_connector.this[0].arn, null)
    }
  }
}
