# ─────────────────────────────────────────────────────────────
#  OIDC Trust — AWS
#
#  Creates an IAM OIDC Provider and IAM Role so GitHub Actions
#  can assume a role without stored access keys.
#
#  Run ONCE per project: task oidc:setup
#  After running, copy the outputs into your GitHub repo variables.
#  Module source: github.com/<<GITHUB_ORG>>/terraform-modules
# ─────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "<<REGION>>"
}

module "oidc" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/oidc/aws?ref=<<MODULES_VERSION>>"

  project_name = "<<APP_NAME>>"
  github_org   = "<<GITHUB_ORG>>"
  region       = "<<REGION>>"
}

output "AWS_ROLE_ARN" {
  value = module.oidc.AWS_ROLE_ARN
}

output "AWS_REGION" {
  value = module.oidc.AWS_REGION
}

output "AWS_ACCOUNT_ID" {
  value = module.oidc.AWS_ACCOUNT_ID
}
