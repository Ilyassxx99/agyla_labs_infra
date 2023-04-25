output "repo_clone_url_http" {
  value = aws_codecommit_repository.ilyass_cicd_lab.clone_url_http
  description = "Repo cloning URL"
}

output "repo_clone_url_ssh" {
  value = aws_codecommit_repository.ilyass_cicd_lab.clone_url_ssh
  description = "Repo cloning URL"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ilyass-cicd-lab.repository_url
  description = "ECR Repo URL"
}

output "catpipeline_bucket_id" {
  value = aws_s3_bucket.codepipeline.id
  description = "ECR Repo URL"
}