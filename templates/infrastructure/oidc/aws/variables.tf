variable "project_name" {
  type        = string
  default     = "<<APP_NAME>>"
}

variable "github_org" {
  type        = string
  default     = "<<GITHUB_ORG>>"
  description = "GitHub username or organisation (e.g. tarek-alabbar)"
}

variable "region" {
  type    = string
  default = "<<REGION>>"
}
