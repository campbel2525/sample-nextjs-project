# providerのプロファイル名
variable "aws_default_profile" {
  type = string
}

# db
variable "db_name" {
  type = string
}
variable "db_init_password" {
  type = string
}

# github
variable "github_fingerprint" {
  type        = string
  description = "fingerprint for GitHub OIDC provider. 全ての文字を小文字に変換すること"
}
variable "github_subject" {
  type        = string
  description = "repo:<github account名>/<リポジトリ名>:ref:refs/heads/<ブランチ名>"
}
