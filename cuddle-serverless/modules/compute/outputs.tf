output "lambda_arn" {
  value = aws_lambda_function.cuddle_serverless.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.cuddle_serverless.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.cuddle_serverless.function_name
}

output "api_lambda_arn" {
  value = aws_lambda_function.cuddle_serverless_api.arn
}

output "api_lambda_invoke_arn" {
  value = aws_lambda_function.cuddle_serverless_api.invoke_arn
}

output "api_lambda_name" {
  value = aws_lambda_function.cuddle_serverless_api.function_name
}

output "sfn_arn" {
  value = aws_sfn_state_machine.cuddle_serverless.arn
}