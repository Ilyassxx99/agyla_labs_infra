resource "aws_cloudwatch_log_group" "cuddle_serverless" {
  name = "ilyass-serverless-lab"
}
resource "aws_cloudwatch_log_group" "cuddle_serverless_access" {
  name = "ilyass-serverless-access-lab"
}