# ─────────────────────────────────────────────────────────────
#  OIDC Trust — Azure
#
#  Creates the App Registration + Federated Identity Credential
#  so GitHub Actions can authenticate without stored secrets.
#
#  Run ONCE per project: task oidc:setup
#  After running, copy the outputs into your GitHub repo variables.
#  Module source: github.com/<<GITHUB_ORG>>/terraform-modules
# ─────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

module "oidc" {
  source = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/oidc/azure?ref=<<MODULES_VERSION>>"

  project_name = "<<APP_NAME>>"
  github_org   = "<<GITHUB_ORG>>"
}

output "AZURE_CLIENT_ID" {
  value = module.oidc.AZURE_CLIENT_ID
}

output "AZURE_TENANT_ID" {
  value = module.oidc.AZURE_TENANT_ID
}

output "AZURE_SUBSCRIPTION_ID" {
  value = module.oidc.AZURE_SUBSCRIPTION_ID
}
