# ─────────────────────────────────────────────────────────────
#  State Bootstrap — Azure
#
#  Provisions the Azure Blob Storage backend for Terraform state.
#  Run ONCE per project: task infra:bootstrap
#
#  Uses LOCAL state intentionally — there is no remote backend yet.
#  Module source: github.com/<<GITHUB_ORG>>/terraform-modules
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

module "state_backend" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/state-backend/azure?ref=<<MODULES_VERSION>>"

  app_name            = "<<APP_NAME>>"
  resource_group_name = "rg-<<APP_NAME>>-tfstate"
  location            = "<<REGION>>"
  tags                = { managed_by = "terraform-bootstrap", app = "<<APP_NAME>>" }
}

output "resource_group_name" {
  value = module.state_backend.resource_group_name
}

output "storage_account_name" {
  value = module.state_backend.storage_account_name
}

output "container_name" {
  value = module.state_backend.container_name
}
