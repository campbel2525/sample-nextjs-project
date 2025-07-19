# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  profile = var.aws_default_profile
}

# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3"
    }
  }

  backend "s3" {
    key = "apprunner_app/terraform.tfstate"
  }
}

# ---------------------------------------------
# Modules
# ---------------------------------------------

module "private_subnet_1a" {
  source = "../../modules/get_subnet"

  subnet_name = "private-subnet-1a"
}

# module "private_subnet_1c" {
#   source = "../../modules/get_subnet"

#   subnet_name = "private-subnet-1c"
# }

module "app_sg" {
  source = "../../modules/get_security_group"

  vpc_name            = "vpc"
  security_group_name = "app-sg"
}

# module "user_front_ecr_repository" {
#   source = "../../modules/get_ecr_repository"

#   repository_name = "user-front-repo"
# }
