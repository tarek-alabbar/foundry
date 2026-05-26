locals {
  # ACR names: alphanumeric only, 5-50 chars
  acr_name = substr(replace(var.app_name, "-", ""), 0, 50)
}

resource "azurerm_container_registry" "acr" {
  name                = "${local.acr_name}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
  tags                = var.tags
}
