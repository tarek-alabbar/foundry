resource "google_cloud_run_v2_service" "app" {
  name     = var.app_name
  location = var.location
  project  = var.project_id

  template {
    containers {
      image = var.image

      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        startup_cpu_boost = true
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = var.port
        }
        initial_delay_seconds = 10
        period_seconds        = 30
      }
    }

    scaling {
      min_instance_count = var.min_replicas
      max_instance_count = var.max_replicas
    }
  }

  labels = var.tags
}

# Allow unauthenticated public access
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
