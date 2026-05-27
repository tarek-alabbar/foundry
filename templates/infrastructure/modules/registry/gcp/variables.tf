variable "app_name" {
  type            = string
}
variable "resource_group_name" {
  type            = string
  default         = ""
}
variable "location" {
  type            = string
  description     = "GCP region"
}
variable "project_id" {
  type            = string
}
variable "tags" {
  type            = map(string)
  default         = {}
}
