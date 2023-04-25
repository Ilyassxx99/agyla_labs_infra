data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

data "archive_file" "api_lambda" {
  type        = "zip"
  source_file = "api_lambda.py"
  output_path = "api_lambda_function_payload.zip"
}

resource "aws_lambda_function" "cuddle_serverless" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "ilyass-serverless-lab"
  role          = var.lambda_role_arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      SENDER_EMAIL = "${var.sender_email}"
    }
  }
}

resource "aws_sfn_state_machine" "cuddle_serverless" {
  name     = "ilyass-serverless-lab"
  role_arn = var.sfn_role_arn
  type = "STANDARD"

  definition = jsonencode({
    StartAt = "Timer"
    States = {
      Timer = {
        Type     = "Wait"
        SecondsPath = "$.waitSeconds"
        Next = "Email"
      }
      Email = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
            FunctionName = "${aws_lambda_function.cuddle_serverless.arn}"
            Payload = {
                "Input.$" = "$"
            }
        }
        Next = "NextState"
      }
      NextState = {
        Type = "Pass"
        End = true
      }
    }
  })
  logging_configuration {
    log_destination        = "${var.cloudwatch_serverless_sfn_arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_lambda_function" "cuddle_serverless_api" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "api_lambda_function_payload.zip"
  function_name = "ilyass-api-serverless-lab"
  role          = var.lambda_role_arn
  handler       = "api_lambda.lambda_handler"

  source_code_hash = data.archive_file.api_lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      SFN_ARN = "${aws_sfn_state_machine.cuddle_serverless.arn}"
    }
  }

}