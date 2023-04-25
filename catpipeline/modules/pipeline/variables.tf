variable "github_access_token_ssm" {
  description = "Github personal access token from SSM Parameter"
  sensitive = true
}

variable "catpipeline_role" {
  description = "CodePipeline IAM Role"
}

variable "catpipeline_deploy_role" {
  description = "CodeDeploy IAM Role"
}

variable "catpipeline_ecs_cluster" {
  description = "ECS Cluster Name"
}

variable "catpipeline_ecs_service" {
  description = "ECS Service Name"
}

variable "catpipeline_tg_A_name" {
  description = "ELB Target Group A Name"
}

variable "catpipeline_tg_B_name" {
  description = "ELB Target Group B Name"
}

variable "catpipeline_lb_listener_arn" {
  description = "ELB Listener Arn"
}

variable "app_source_github_repo" {
  description = "GitHub Repository of Source App Code"
}

variable "catpipeline_bucket_id" {
  description = "Pipeline S3 Bucket ID"
}

variable "catpipeline_ecr_name" {
  description = "ECR Repo name"
}