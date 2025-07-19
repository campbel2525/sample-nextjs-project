data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "role" {
  name               = "amplify-${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json
}
resource "aws_iam_role_policy_attachment" "amplify_admin_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}
resource "aws_iam_policy" "ssm_read_policy" {
  name        = "AmplifySSMReadAccessPolicy"
  description = "Allows Amplify to read specific SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ssm:GetParameter"
        Effect = "Allow"
        # アクセスを特定のパラメータに限定するのがベストプラクティス
        Resource = aws_ssm_parameter.app_env.arn
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_read_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.ssm_read_policy.arn
}
