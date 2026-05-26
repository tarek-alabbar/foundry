output "url" {
  description = "Public URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.app.name
}
