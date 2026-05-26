output "url" {
  description = "Artifact Registry repository URL"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.app_name}"
}

output "name" {
  value = google_artifact_registry_repository.app.name
}

output "admin_username" {
  value = "_json_key"
}

output "admin_password" {
  description = "Use a service account key or workload identity"
  value       = ""
  sensitive   = true
}
