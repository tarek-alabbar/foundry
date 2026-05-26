output "resource_group_name" {
  value       = azurerm_resource_group.tfstate.name
  description = "Use this in your backend.hcl files"
}

output "storage_account_name" {
  value       = azurerm_storage_account.tfstate.name
  description = "Use this in your backend.hcl files"
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
