# ─────────────────────────────────────────────────────────────
#  Container Runtime Module — GCP Cloud Run
#
#  Variable names are IDENTICAL across azure/aws/gcp so the
#  calling environment main.tf never needs to change cloud.
# ─────────────────────────────────────────────────────────────

variable "app_name" {
  type            = string
}
variable "resource_group_name" {
  type            = string
  description     = "Maps to GCP: not used, kept for interface parity"
}
variable "location" {
  type            = string
  description     = "GCP region"
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
  default         = "1"
  description     = "GCP vCPU count (1/2/4/8)"
}
variable "memory" {
  type            = string
  default         = "512Mi"
  description     = "GCP memory (128Mi..32Gi)"
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
  description     = "Maps to GCP: not used, kept for interface parity"
}
variable "registry_server" {
  type            = string
}
variable "registry_username" {
  type            = string
  default         = "_json_key"
}
variable "registry_password" {
  type            = string
  sensitive       = true
}
variable "project_id" {
  type            = string
}
variable "tags" {
  type            = map(string)
  default         = {}
}
