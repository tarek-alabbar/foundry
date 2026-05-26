variable "app_name"     { type = string  default = "<<APP_NAME>>" }
variable "team"         { type = string  default = "<<TEAM>>" }
variable "environment"  { type = string }
variable "location"     { type = string  default = "<<REGION>>" }
variable "image_tag"    { type = string  default = "latest" }
variable "port"         { type = number  default = <<PORT>> }
variable "cpu"          { type = string  default = "<<CPU>>" }
variable "memory"       { type = string  default = "<<MEMORY>>" }
variable "min_replicas" { type = number  default = 0 }
variable "max_replicas" { type = number  default = 3 }
variable "env_vars"     { type = map(string)  default = {} }
