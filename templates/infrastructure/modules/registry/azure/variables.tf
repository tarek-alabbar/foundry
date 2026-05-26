variable "app_name"            { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "sku"                 { type = string  default = "Basic"  description = "Basic | Standard | Premium" }
variable "tags"                { type = map(string)  default = {} }
