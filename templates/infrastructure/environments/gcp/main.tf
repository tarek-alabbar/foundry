terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {}   # configured via backend.hcl — run: task infra:init ENV=<env>
}

provider "google" {
  project = var.project_id
  region  = var.location
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
  source     = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/networking/gcp?ref=<<MODULES_VERSION>>"
  app_name   = "${var.app_name}-${var.environment}"
  location   = var.location
  project_id = var.project_id
  tags       = local.tags
}

# ── Registry ───────────────────────────────────────────────────

module "registry" {
  source     = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/registry/gcp?ref=<<MODULES_VERSION>>"
  app_name   = var.app_name
  location   = var.location
  project_id = var.project_id
  tags       = local.tags
}

# ── Container Runtime ──────────────────────────────────────────

module "app" {
  source              = "git::https://github.com/<<GITHUB_ORG>>/terraform-modules.git//modules/container-runtime/gcp?ref=<<MODULES_VERSION>>"
  app_name            = "${var.app_name}-${var.environment}"
  resource_group_name = ""
  location            = var.location
  project_id          = var.project_id
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
