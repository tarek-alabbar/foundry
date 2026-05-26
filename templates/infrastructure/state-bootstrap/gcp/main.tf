# ─────────────────────────────────────────────────────────────
#  State Bootstrap — GCP
#
#  Creates a GCS bucket for Terraform state.
#  Run ONCE per project: task infra:bootstrap
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
  project = var.project_id
  region  = var.location
}

resource "google_storage_bucket" "tfstate" {
  name          = "${replace(var.app_name, "-", "")}tfstate"
  location      = upper(var.location)
  project       = var.project_id
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  labels = { managed_by = "terraform-bootstrap", app = replace(var.app_name, "-", "_") }
}
