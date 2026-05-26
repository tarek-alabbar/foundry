# ─────────────────────────────────────────────────────────────
#  Container Runtime Module — AWS ECS Fargate
#
#  Variable names are IDENTICAL across azure/aws/gcp so the
#  calling environment main.tf never needs to change cloud.
# ─────────────────────────────────────────────────────────────

variable "app_name"           { type = string }
variable "resource_group_name" { type = string  description = "Maps to AWS: not used, kept for interface parity" }
variable "location"           { type = string  description = "AWS region" }
variable "image"              { type = string  description = "Full image URI including tag" }
variable "port"               { type = number  default = 3000 }
variable "cpu"                { type = string  default = "512"   description = "ECS CPU units (256/512/1024/2048/4096)" }
variable "memory"             { type = string  default = "1024"  description = "ECS memory in MiB (512/1024/2048/4096)" }
variable "env_vars"           { type = map(string)  default = {} }
variable "min_replicas"       { type = number  default = 1 }
variable "max_replicas"       { type = number  default = 3 }
variable "environment_id"     { type = string  description = "Maps to AWS: VPC ID" }
variable "registry_server"    { type = string  description = "ECR registry URI" }
variable "registry_username"  { type = string  default = "AWS" }
variable "registry_password"  { type = string  sensitive = true }
variable "subnet_ids"         { type = list(string) }
variable "security_group_ids" { type = list(string)  default = [] }
variable "tags"               { type = map(string)  default = {} }
