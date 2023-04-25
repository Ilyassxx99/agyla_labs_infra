output "ecr_repo_url" {
  value = module.storage.ecr_repo_url
  description = "ECR Repo URL for dev environment"
}

output "vpc_id" {
  value = module.network.catpipeline_vpc_id
  description = "VPC ID of catpipeline"
}