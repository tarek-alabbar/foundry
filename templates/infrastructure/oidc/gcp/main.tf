# ─────────────────────────────────────────────────────────────
#  OIDC Trust — GCP (Workload Identity Federation)
#
#  Creates a Workload Identity Pool + Provider so GitHub Actions
#  can authenticate to GCP without any stored service account keys.
#
#  Run once per project: task oidc:setup
#  After running, copy the outputs into your GitHub repo variables.
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
  region  = var.region
}

# Workload Identity Pool — container for external identity providers
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "${var.project_name}-github"
  display_name              = "GitHub Actions — ${var.project_name}"
  description               = "Allows GitHub Actions to authenticate without service account keys"
}

# GitHub OIDC Provider within the pool
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub"

  # Map GitHub token claims to Google attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.actor"      = "assertion.actor"
  }

  # Only allow tokens from your GitHub org/user
  attribute_condition = "attribute.repository == '${var.github_org}/${var.project_name}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service Account that GitHub Actions will impersonate
resource "google_service_account" "ci" {
  project      = var.project_id
  account_id   = "${var.project_name}-ci"
  display_name = "CI — ${var.project_name}"
  description  = "Impersonated by GitHub Actions via Workload Identity"
}

# Allow the Workload Identity Pool to impersonate the service account
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.project_name}"
}

# Grant Editor role so CI can manage project resources
resource "google_project_iam_member" "ci_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.ci.email}"
}
