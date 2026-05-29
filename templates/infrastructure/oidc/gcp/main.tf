# ─────────────────────────────────────────────────────────────
#  OIDC Trust — GCP (Workload Identity Federation)
#
#  Creates a Workload Identity Pool + Provider so GitHub Actions
#  can authenticate to GCP without any stored service account keys.
#
#  Run ONCE per project: task oidc:setup
#  After running, copy the outputs into your GitHub repo variables.
#  Module source: github.com/<<GITHUB_ORG>>/terraform-modules
# ─────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "<<GCP_PROJECT_ID>>"
  region  = "<<REGION>>"
}

module "oidc" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/oidc/gcp?ref=<<MODULES_VERSION>>"

  project_name = "<<APP_NAME>>"
  github_org   = "<<GITHUB_ORG>>"
  project_id   = "<<GCP_PROJECT_ID>>"
  region       = "<<REGION>>"
}

output "GCP_WORKLOAD_IDENTITY_PROVIDER" {
  value = module.oidc.GCP_WORKLOAD_IDENTITY_PROVIDER
}

output "GCP_SERVICE_ACCOUNT" {
  value = module.oidc.GCP_SERVICE_ACCOUNT
}

output "GCP_PROJECT_ID" {
  value = module.oidc.GCP_PROJECT_ID
}
