output "cloudwatch_serverless_sfn_arn" {
  value = aws_cloudwatch_log_group.cuddle_serverless.arn
}

output "cloudwatch_serverless_access_arn" {
  value = aws_cloudwatch_log_group.cuddle_serverless_access.arn
}