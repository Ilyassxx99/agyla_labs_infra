output "serverless_api_invoke_url" {
  value = aws_api_gateway_stage.cuddle_serverless.invoke_url
}