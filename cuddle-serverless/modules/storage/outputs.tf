output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.cuddle_serverless.website_endpoint
}