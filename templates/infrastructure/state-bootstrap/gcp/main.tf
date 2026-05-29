# ─────────────────────────────────────────────────────────────
#  State Bootstrap — GCP
#
#  Provisions the GCS bucket for Terraform state.
#  Run ONCE per project: task infra:bootstrap
#
#  Uses LOCAL state intentionally — there is no remote backend yet.
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

module "state_backend" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/state-backend/gcp?ref=<<MODULES_VERSION>>"

  app_name   = "<<APP_NAME>>"
  location   = "<<REGION>>"
  project_id = "<<GCP_PROJECT_ID>>"
  tags       = { managed_by = "terraform-bootstrap", app = "<<APP_NAME>>" }
}

output "bucket_name" {
  value = module.state_backend.bucket_name
}
