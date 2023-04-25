resource "aws_api_gateway_rest_api" "cuddle_serverless" {
  name = "ilyass-serverless-lab"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.serverless_lambda_api_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.cuddle_serverless.execution_arn}/*"
}

resource "aws_api_gateway_account" "cuddle_serverless" {
  cloudwatch_role_arn = var.cloudwatch_serverless_logs_role_arn
}

resource "aws_api_gateway_stage" "cuddle_serverless" {
  deployment_id = aws_api_gateway_deployment.cuddle_serverless.id
  rest_api_id   = aws_api_gateway_rest_api.cuddle_serverless.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = var.cloudwatch_serverless_access_arn
    format = "$context.extendedRequestId"
  }
}

resource "aws_api_gateway_resource" "cuddle_serverless" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  parent_id   = aws_api_gateway_rest_api.cuddle_serverless.root_resource_id
  path_part   = "petcuddleotron"
}

resource "aws_api_gateway_method" "cuddle_serverless_cors" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cuddle_serverless_cors" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = aws_api_gateway_method.cuddle_serverless_cors.http_method
  status_code = "200"
  
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Credentials"  = true
  }
}

resource "aws_api_gateway_integration" "cuddle_serverless_cors" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = aws_api_gateway_method.cuddle_serverless_cors.http_method

  type = "MOCK"
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = aws_api_gateway_method.cuddle_serverless_cors.http_method
  status_code = aws_api_gateway_method_response.cuddle_serverless_cors.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.cuddle_serverless_cors
  ]
}

resource "aws_api_gateway_method" "cuddle_serverless_post" {
  rest_api_id   = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id   = aws_api_gateway_resource.cuddle_serverless.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_method_response" "cuddle_serverless_post" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = aws_api_gateway_method.cuddle_serverless_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Credentials"  = true
  }
  depends_on = [
    aws_api_gateway_method.cuddle_serverless_post
  ]
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id             = aws_api_gateway_resource.cuddle_serverless.id
  http_method             = aws_api_gateway_method.cuddle_serverless_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.serverless_lambda_api_invoke_arn
}

resource "aws_api_gateway_integration_response" "lambda_post" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id
  resource_id = aws_api_gateway_resource.cuddle_serverless.id
  http_method = aws_api_gateway_method.cuddle_serverless_post.http_method
  status_code = aws_api_gateway_method_response.cuddle_serverless_post.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]
}

resource "aws_api_gateway_deployment" "cuddle_serverless" {
  rest_api_id = aws_api_gateway_rest_api.cuddle_serverless.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.cuddle_serverless.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.cuddle_serverless_cors,
    aws_api_gateway_method.cuddle_serverless_post,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.cuddle_serverless_cors,
  ]
}