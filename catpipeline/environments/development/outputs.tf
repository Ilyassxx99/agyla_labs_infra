output "repo_clone_url_http" {
  value = module.pipeline.repo_clone_url_http
  description = "Repo cloning URL for dev environment"
}

output "repo_clone_url_ssh" {
  value = module.pipeline.repo_clone_url_ssh
  description = "Repo cloning URL for dev environment"
}

output "ecr_repo_url" {
  value = module.pipeline.ecr_repo_url
  description = "ECR Repo URL for dev environment"
}

output "vpc_id" {
  value = module.network.catpipeline_vpc_id
  description = "VPC ID of catpipeline"
}