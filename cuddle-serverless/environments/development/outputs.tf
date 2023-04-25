output "ses_sender_email" {
  value = var.sender_email
  description = "Email adress used by SES to send"
}

output "lambda_arn" {
  value = module.compute.lambda_arn
  description = "ARN of Lambda function"
}

output "sfn_arn" {
  value = module.compute.sfn_arn
  description = "ARN of SFN"
}

output "api_invoke_url" {
  value = module.api.serverless_api_invoke_url
  description = "URL of Api Gateway Stage"
}

output "website_endpoint" {
  value = module.storage.website_endpoint
  description = "URL of S3 Static Website"
}