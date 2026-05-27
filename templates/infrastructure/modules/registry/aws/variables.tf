variable "app_name" {
  type            = string
}
variable "resource_group_name" {
  type            = string
  default         = ""
}
variable "location" {
  type            = string
  description     = "AWS region"
}
variable "tags" {
  type            = map(string)
  default         = {}
}
