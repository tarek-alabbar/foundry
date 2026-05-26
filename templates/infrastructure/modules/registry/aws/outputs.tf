output "url" {
  description = "ECR repository URI"
  value       = aws_ecr_repository.app.repository_url
}

output "name" {
  value = aws_ecr_repository.app.name
}

output "admin_username" {
  value = "AWS"
}

output "admin_password" {
  description = "Retrieve with: aws ecr get-login-password"
  value       = ""
  sensitive   = true
}
