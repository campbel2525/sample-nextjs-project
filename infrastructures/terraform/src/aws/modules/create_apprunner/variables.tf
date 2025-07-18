variable "app_name" {
  type        = string
  description = "ケバブケースで指定してください。例: user-front"
}

variable "apprunner_cpu" {
  type = number
}

variable "apprunner_memory" {
  type = number
}

variable "apprunner_port" {
  type = number
}

variable "apprunner_auto_deployments_enabled" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "ssm_parameter_app_env_names" {
  type    = list(string)
  default = []
}

# variable "ecr_repository_url" {
#   type = string
# }
