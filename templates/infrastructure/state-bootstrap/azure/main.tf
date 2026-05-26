# ─────────────────────────────────────────────────────────────
#  State Bootstrap — Azure
#
#  Creates the Azure Blob Storage backend for Terraform state.
#  Run ONCE per project: task infra:bootstrap
#
#  Uses LOCAL state intentionally (it bootstraps the remote state —
#  there's no chicken-and-egg problem this way).
# ─────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.app_name}-tfstate"
  location = var.location
  tags     = { managed_by = "terraform-bootstrap", app = var.app_name }
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "${substr(replace(var.app_name, "-", ""), 0, 18)}tfstate"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = { managed_by = "terraform-bootstrap", app = var.app_name }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
