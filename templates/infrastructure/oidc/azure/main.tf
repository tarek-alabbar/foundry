# ─────────────────────────────────────────────────────────────
#  OIDC Trust — Azure
#
#  Creates an App Registration with a Federated Identity Credential
#  so GitHub Actions can authenticate to Azure without any stored secrets.
#
#  Run once per project: task oidc:setup
#  After running, copy the outputs into your GitHub repo variables.
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

data "azurerm_subscription" "current" {}
data "azuread_client_config" "current" {}

# App Registration — the identity CI will assume
resource "azuread_application" "ci" {
  display_name = "${var.project_name}-ci"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "ci" {
  client_id = azuread_application.ci.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Federated credential — trusts tokens from GitHub Actions for this repo
resource "azuread_application_federated_identity_credential" "main_branch" {
  application_id = azuread_application.ci.id
  display_name   = "github-main"
  description    = "GitHub Actions on main branch for ${var.github_org}/${var.project_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.project_name}:ref:refs/heads/main"
}

resource "azuread_application_federated_identity_credential" "pull_request" {
  application_id = azuread_application.ci.id
  display_name   = "github-pr"
  description    = "GitHub Actions on pull requests for ${var.github_org}/${var.project_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.project_name}:pull_request"
}

# Grant Contributor on the subscription so CI can manage all project resources
resource "azurerm_role_assignment" "ci_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ci.object_id
}
