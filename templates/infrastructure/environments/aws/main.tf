terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}   # configured via backend.hcl — run: task infra:init ENV=<env>
}

provider "aws" {
  region = var.location
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
  source   = "../../modules/networking"
  app_name = "${var.app_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

# ── Registry ───────────────────────────────────────────────────

module "registry" {
  source   = "../../modules/registry"
  app_name = var.app_name
  location = var.location
  tags     = local.tags
}

# ── Container Runtime ──────────────────────────────────────────

module "app" {
  source              = "../../modules/container-runtime"
  app_name            = "${var.app_name}-${var.environment}"
  resource_group_name = ""
  location            = var.location
  image               = "${module.registry.url}:${var.image_tag}"
  port                = var.port
  cpu                 = var.cpu
  memory              = var.memory
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas
  env_vars            = var.env_vars
  environment_id      = module.networking.environment_id
  subnet_ids          = module.networking.subnet_ids
  registry_server     = module.registry.url
  registry_username   = module.registry.admin_username
  registry_password   = module.registry.admin_password
  tags                = local.tags
}
