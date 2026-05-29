terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {}   # configured via backend.hcl — run: task infra:init ENV=<env>
}

provider "azurerm" {
  features {}
}

# ── Resource Group ─────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

locals {
  tags = {
    app         = var.app_name
    environment = var.environment
    team        = var.team
    managed_by  = "terraform"
  }
}

# ── Networking ─────────────────────────────────────────────────

module "networking" {
  source              = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/networking/azure?ref=<<MODULES_VERSION>>"
  app_name            = "${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags
}

# ── Registry ───────────────────────────────────────────────────

module "registry" {
  source              = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/registry/azure?ref=<<MODULES_VERSION>>"
  app_name            = replace("${var.app_name}${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags
}

# ── Container Runtime ──────────────────────────────────────────

module "app" {
  source              = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/container-runtime/azure?ref=<<MODULES_VERSION>>"
  app_name            = "${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  image               = "${module.registry.url}/${var.app_name}:${var.image_tag}"
  port                = var.port
  cpu                 = var.cpu
  memory              = var.memory
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas
  env_vars            = var.env_vars
  environment_id      = module.networking.environment_id
  registry_server     = module.registry.url
  registry_username   = module.registry.admin_username
  registry_password   = module.registry.admin_password
  tags                = local.tags
}
