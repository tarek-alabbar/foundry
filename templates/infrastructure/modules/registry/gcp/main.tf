resource "google_artifact_registry_repository" "app" {
  provider      = google
  project       = var.project_id
  location      = var.location
  repository_id = var.app_name
  format        = "DOCKER"
  description   = "Container registry for ${var.app_name}"
  labels        = var.tags
}
