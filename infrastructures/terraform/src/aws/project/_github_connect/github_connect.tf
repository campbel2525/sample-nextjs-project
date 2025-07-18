################################################################################
# modules/github_oidc/roles.tf
# GitHub Actions OIDC 用 IAMリソースの作成
################################################################################

# 1) GitHub OIDC プロバイダー定義
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_fingerprint] # GitHub OIDC用ルートCAのSHA-1フィンガープリント
}

# 共通の信頼ポリシードキュメント
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_subject]
    }
  }
}

# 2) ECRプッシュ専用ロール
resource "aws_iam_role" "github_ecr_role" {
  name               = "github-actions-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

data "aws_iam_policy_document" "ecr_push_policy" {
  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [module.user_front_ecr_repository.repository_arn]
  }
}

resource "aws_iam_role_policy" "github_ecr_policy" {
  name   = "github-actions-ecr-policy"
  role   = aws_iam_role.github_ecr_role.id
  policy = data.aws_iam_policy_document.ecr_push_policy.json
}

# 3) App Runner更新専用ロール
resource "aws_iam_role" "github_deploy_role" {
  name               = "github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

data "aws_iam_policy_document" "apprunner_update_policy" {
  statement {
    sid       = "AppRunnerUpdate"
    effect    = "Allow"
    actions   = ["apprunner:UpdateService"]
    resources = [module.user_front_apprunner.apprunner_service_arn]
  }
}

resource "aws_iam_role_policy" "github_deploy_policy" {
  name   = "github-actions-deploy-policy"
  role   = aws_iam_role.github_deploy_role.id
  policy = data.aws_iam_policy_document.apprunner_update_policy.json
}
