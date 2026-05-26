output "bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "Use this as 'bucket' in your backend.hcl files"
}

output "dynamodb_table" {
  value       = aws_dynamodb_table.tfstate_lock.name
  description = "Use this as 'dynamodb_table' in your backend.hcl files"
}
