output "bucket_name" {
  value       = google_storage_bucket.tfstate.name
  description = "Use this as 'bucket' in your backend.hcl files"
}
