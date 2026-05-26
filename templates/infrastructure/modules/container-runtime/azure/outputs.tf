output "url" {
  description = "Public URL of the container app"
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
}

output "name" {
  description = "Container app resource name"
  value       = azurerm_container_app.app.name
}
