# ─────────────────────────────────────────────────────────────
#  After running `task oidc:setup`, add these values as
#  Variables (not secrets) in your GitHub repo:
#  Settings → Secrets and variables → Actions → Variables
# ─────────────────────────────────────────────────────────────

output "AZURE_CLIENT_ID" {
  value       = azuread_application.ci.client_id
  description = "Add as a GitHub Actions variable: AZURE_CLIENT_ID"
}

output "AZURE_TENANT_ID" {
  value       = data.azuread_client_config.current.tenant_id
  description = "Add as a GitHub Actions variable: AZURE_TENANT_ID"
}

output "AZURE_SUBSCRIPTION_ID" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Add as a GitHub Actions variable: AZURE_SUBSCRIPTION_ID"
}
