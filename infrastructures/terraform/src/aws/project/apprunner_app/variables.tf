# providerのプロファイル名
variable "aws_default_profile" {
  type = string
}

# GitHubのデプロイ関連
variable "github_repository_url" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_branch_name" {
  type = string
}

# db
variable "db_name" {
  type = string
}
variable "db_init_password" {
  type = string
}
