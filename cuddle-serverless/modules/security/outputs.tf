output "serverless_lambda_role_arn" {
  value = aws_iam_role.cuddle_serverless_lambda.arn
  description = "Lambda IAM Role"
}

output "serverless_sfn_role_arn" {
  value = aws_iam_role.cuddle_serverless_sfn.arn
  description = "StatesMachine IAM Role"
}
