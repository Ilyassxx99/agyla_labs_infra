output "catpipeline_bucket_id" {
  value = aws_s3_bucket.catpipeline.id
  description = "ECR S3 Bucket ID"
}

output "catpipeline_ecr_name" {
  value = aws_ecr_repository.ilyass-cicd-lab.name
  description = "ECR S3 Bucket ID"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ilyass-cicd-lab.repository_url
  description = "ECR Repo URL"
}
