# ─────────────────────────────────────────────────────────────
#  After running `task oidc:setup`, add these values as
#  Variables in your GitHub repo:
#  Settings → Secrets and variables → Actions → Variables
# ─────────────────────────────────────────────────────────────

output "GCP_WORKLOAD_IDENTITY_PROVIDER" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Add as a GitHub Actions variable: GCP_WORKLOAD_IDENTITY_PROVIDER"
}

output "GCP_SERVICE_ACCOUNT" {
  value       = google_service_account.ci.email
  description = "Add as a GitHub Actions variable: GCP_SERVICE_ACCOUNT"
}

output "GCP_PROJECT_ID" {
  value       = var.project_id
  description = "Add as a GitHub Actions variable: GCP_PROJECT_ID"
}
