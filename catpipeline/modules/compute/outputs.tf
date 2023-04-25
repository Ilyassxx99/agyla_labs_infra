output "catpipeline_ecs_cluster" {
  description = "ECS Cluster Name"
  value = aws_ecs_cluster.catpipeline.name
}

output "catpipeline_ecs_service" {
  description = "ECS Service Name"
  value = aws_ecs_service.catpipeline.name
}

output "catpipeline_tg_A_name" {
  description = "ELB Target Group A Name"
  value = aws_lb_target_group.catpipeline_A.name
}

output "catpipeline_tg_B_name" {
  description = "ELB Target Group B Name"
  value = aws_lb_target_group.catpipeline_B.name
}

output "catpipeline_lb_listener_arn" {
  description = "ELB Listener Arn"
  value = aws_lb_listener.catpipeline.arn
}

output "catpipeline_task_def_arn" {
  description = "ELB Listener Arn"
  value = aws_ecs_task_definition.catpipeline.arn
}