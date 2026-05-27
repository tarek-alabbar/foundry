# ─────────────────────────────────────────────────────────────
#  Container Runtime Module — Azure Container Apps
#
#  Variable names are IDENTICAL across azure/aws/gcp so the
#  calling environment main.tf never needs to change cloud.
# ─────────────────────────────────────────────────────────────

variable "app_name" {
  type            = string
}
variable "resource_group_name" {
  type            = string
}
variable "location" {
  type            = string
}
variable "image" {
  type            = string
  description     = "Full image URI including tag"
}
variable "port" {
  type            = number
  default         = 3000
}
variable "cpu" {
  type            = string
  default         = "0.5"
}
variable "memory" {
  type            = string
  default         = "1Gi"
}
variable "env_vars" {
  type            = map(string)
  default         = {}
}
variable "min_replicas" {
  type            = number
  default         = 0
}
variable "max_replicas" {
  type            = number
  default         = 3
}
variable "environment_id" {
  type            = string
  description     = "Container App Environment ID"
}
variable "registry_server" {
  type            = string
}
variable "registry_username" {
  type            = string
}
variable "registry_password" {
  type            = string
  sensitive       = true
}
variable "tags" {
  type            = map(string)
  default         = {}
}
