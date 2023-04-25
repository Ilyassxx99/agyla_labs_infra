variable "ecr_repo_url" {
  description = "URL of ECR Repo"
  default = "empty"
}

variable "vpc_id" {
  description = "ID of main VPC"
}

variable "container_name" {
  description = "Name of Task DEfinition Container"
}

variable "container_port" {
  description = "Name of Task DEfinition Container"
  type = number
}

variable "task_def_name" {
  description = "Name of Task DEfinition Container"
}

variable "lb_logs_bucket_id" {
  description = "ID of S3 Bucket used to store access logs"
}

variable "ecs_task_role_arn" {
  description = "ARN of ECS role"
  default = "empty"
}

variable "ecs_subnet_primary_id" {
  description = "ID of subnet to use by ECS"
}

variable "ecs_subnet_secondary_id" {
  description = "ID of subnet to use by ECS"
}


variable "ecs_sg_id" {
  description = "ID of security group to use by ECS"
}