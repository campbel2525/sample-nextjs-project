variable "app_name" {
  type        = string
  description = "ケバブケースで指定してください。例: user-front"
}
variable "github_repository_url" {
  type = string
}
variable "github_token" {
  type = string
}
variable "github_branch_name" {
  type = string
}

variable "amplify_platform" {
  type = string
}
variable "amplify_branch_framework" {
  type = string
}
variable "amplify_branch_stage" {
  type = string
}
