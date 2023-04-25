output "catpipeline_github_token_ssm_name" {
  value = aws_ssm_parameter.catpipeline_github_token.name
  description = "SSM Parameter holding Github access token"
}

output "catpipeline_role_name" {
  value = aws_iam_role.catpipeline.name
  description = "CodePipeline IAM Role"
}

output "catpipeline_role_arn" {
  value = aws_iam_role.catpipeline.arn
  description = "CodePipeline IAM Role"
}

output "catpipeline_deploy_role_arn" {
  value = aws_iam_role.catpipeline_deploy.arn
  description = "CodeDeploy IAM Role"
}

output "test_instance_profile_name" {
  value = aws_iam_instance_profile.test_profile.name
  description = "Name of Instance Profile"
}