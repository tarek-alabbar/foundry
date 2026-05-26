output "url" {
  description = "ECS service URL (via public IP; wire an ALB for a stable URL)"
  value       = "http://${var.app_name}.${var.location}.ecs"
}

output "name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}
