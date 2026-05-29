# ─────────────────────────────────────────────────────────────
#  State Bootstrap — AWS
#
#  Provisions the S3 + DynamoDB backend for Terraform state.
#  Run ONCE per project: task infra:bootstrap
#
#  Uses LOCAL state intentionally — there is no remote backend yet.
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

module "state_backend" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/state-backend/aws?ref=<<MODULES_VERSION>>"

  app_name = "<<APP_NAME>>"
  location = "<<REGION>>"
  tags     = { managed_by = "terraform-bootstrap", app = "<<APP_NAME>>" }
}

output "bucket_name" {
  value = module.state_backend.bucket_name
}

output "dynamodb_table" {
  value = module.state_backend.dynamodb_table
}
