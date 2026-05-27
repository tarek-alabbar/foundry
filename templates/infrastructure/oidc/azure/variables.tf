variable "project_name" {
  type        = string
  default     = "<<APP_NAME>>"
  description = "Project name — used for the App Registration display name"
}

variable "github_org" {
  type        = string
  default     = "<<GITHUB_ORG>>"
  description = "GitHub username or organisation (e.g. tarek-alabbar)"
}
