output "cluster_id" {
  value = aws_ecs_cluster.gatus.id
}

output "service_name" {
  value = aws_ecs_service.gatus.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.gatus.arn
}