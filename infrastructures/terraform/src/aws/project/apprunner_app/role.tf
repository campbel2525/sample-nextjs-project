# ----------------------------------------------------------------
# 3. GitHub Actions用 OIDC連携ロール
#    - GitHub ActionsがAWS APIを操作（デプロイ開始）するためのロール
# ----------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # 最新のThumbprintは公式ドキュメントで確認してください
  thumbprint_list = [var.github_fingerprint]
}

# GitHub Actionsが引き受けるためのロール
resource "aws_iam_role" "github_actions_role" {
  name = "user-front-apprunner-github-actions-role"

  # OIDCプロバイダー経由での引き受けを許可
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # ★重要：あなたのGitHubリポジトリに合わせて変更してください
            "token.actions.githubusercontent.com:sub" : var.github_subject
          }
        }
      }
    ]
  })
}
resource "aws_iam_policy" "github_actions_apprunner_policy" {
  # name        = "GitHubActions-AppRunnerStartDeployment"
  # description = "Allows starting a deployment on App Runner"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "apprunner:StartDeployment",
          "apprunner:DescribeService" # デプロイ状況の確認に便利
        ]
        Resource = module.user_front_apprunner.apprunner_service_arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_apprunner_policy.arn
}
