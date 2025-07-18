module "user_front_apprunner" {
  source = "../../modules/create_apprunner"

  app_name                           = "user-front"
  apprunner_cpu                      = 256
  apprunner_memory                   = 512
  apprunner_port                     = 3000
  apprunner_auto_deployments_enabled = false # 初期のデプロイはfalseにする
  subnet_ids = [
    module.private_subnet_1a.id,
    module.private_subnet_1c.id,
  ]
  security_group_ids = [
    module.app_sg.id,
  ]
  ssm_parameter_app_env_names = [
    "/apprunner/user-front/env/SECRET_KEY",
    "/apprunner/user-front/env/FRONTEND_API_URL",
    "/apprunner/user-front/env/DATABASE_URL",
    "/apprunner/user-front/env/NEXTAUTH_URL",
    "/apprunner/user-front/env/NEXTAUTH_SECRET",
  ]
  ecr_repository_url = module.user_front_ecr_repository.repository_url
}
