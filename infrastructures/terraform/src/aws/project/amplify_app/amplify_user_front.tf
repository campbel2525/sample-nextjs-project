module "user_front" {
  source = "../../modules/create_amplify"

  app_name                 = "user-front"
  github_repository_url    = var.github_repository_url
  github_token             = var.github_token
  github_branch_name       = var.github_branch_name
  amplify_platform         = "WEB_COMPUTE"
  amplify_branch_framework = "Next.js - SSR"
  amplify_branch_stage     = "PRODUCTION"
}

# # AmplifyとVPCを接続するVPCコネクタを定義
# resource "aws_amplify_vpc_connector" "user_front_connector" {
#   # 接続対象のAmplifyアプリのIDを指定
#   app_id = module.user_front.amplify_app_id # ← moduleからの出力が必要

#   # 接続先のプライベートサブネットのIDをnetworkのtfstateから取得
#   subnet_ids = [
#     module.private_subnet_1a.id,
#     module.private_subnet_1c.id,
#   ]

#   # Amplifyに適用するセキュリティグループのIDをnetworkのtfstateから取得
#   security_group_ids = [module.amplify_sg.id]
# }
