variable "app_name"   { type = string }
variable "location"   { type = string  description = "AWS region" }
variable "vpc_cidr"   { type = string  default = "10.0.0.0/16" }
variable "tags"       { type = map(string)  default = {} }
