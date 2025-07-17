variable "app_name" {
  type        = string
  description = "ケバブケースで指定してください。例: user-front"
}

variable "github_repository_url" {
  type = string
}

variable "github_branch_name" {
  type = string
}

variable "apprunner_cpu" {
  type = number
}

variable "apprunner_memory" {
  type = number
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "apprunner_connection_arn" {
  type = string
}
