variable "app_name" {
  type            = string
}
variable "resource_group_name" {
  type            = string
}
variable "location" {
  type            = string
}
variable "vnet_cidr" {
  type            = string
  default         = "10.0.0.0/16"
}
variable "subnet_cidr" {
  type            = string
  default         = "10.0.1.0/24"
}
variable "tags" {
  type            = map(string)
  default         = {}
}
