# ─────────────────────────────────────────────────────────────
#  After running `task oidc:setup`, add these values as
#  Variables in your GitHub repo:
#  Settings → Secrets and variables → Actions → Variables
# ─────────────────────────────────────────────────────────────

output "AWS_ROLE_ARN" {
  value       = aws_iam_role.ci.arn
  description = "Add as a GitHub Actions variable: AWS_ROLE_ARN"
}

output "AWS_REGION" {
  value       = var.region
  description = "Add as a GitHub Actions variable: AWS_REGION"
}

output "AWS_ACCOUNT_ID" {
  value       = data.aws_caller_identity.current.account_id
  description = "Add as a GitHub Actions variable: AWS_ACCOUNT_ID"
}
