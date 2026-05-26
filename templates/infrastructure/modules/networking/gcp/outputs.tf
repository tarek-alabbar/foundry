output "network_id"      { value = google_compute_network.main.id }
output "subnet_id"       { value = google_compute_subnetwork.apps.id }
output "connector_id"    { value = google_vpc_access_connector.main.id }
output "environment_id"  { value = google_compute_network.main.id  description = "Network ID — passed to container-runtime as environment_id" }
