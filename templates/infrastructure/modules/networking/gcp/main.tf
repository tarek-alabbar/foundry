resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "vpc-${var.app_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "apps" {
  project       = var.project_id
  name          = "snet-apps-${var.app_name}"
  region        = var.location
  network       = google_compute_network.main.id
  ip_cidr_range = var.vpc_cidr
}

# VPC connector lets Cloud Run services reach resources in the VPC
resource "google_vpc_access_connector" "main" {
  project       = var.project_id
  name          = "conn-${substr(var.app_name, 0, 20)}"
  region        = var.location
  network       = google_compute_network.main.id
  ip_cidr_range = "10.8.0.0/28"
}
