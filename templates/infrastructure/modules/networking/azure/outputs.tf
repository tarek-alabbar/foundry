output "vnet_id"             { value = azurerm_virtual_network.main.id }
output "subnet_id"           { value = azurerm_subnet.apps.id }
output "environment_id"      { value = azurerm_container_app_environment.main.id }
output "environment_name"    { value = azurerm_container_app_environment.main.name }
