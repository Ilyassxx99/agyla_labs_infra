data "aws_iam_policy_document" "cuddle_serverless_assume" {
  statement {
    actions = [ "sts:AssumeRole" ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ 
        "lambda.amazonaws.com",
        "states.amazonaws.com",
        "apigateway.amazonaws.com",  
         ]
    }
  }
}

data "aws_iam_policy_document" "cuddle_serverless_lambda" {
    statement {
      actions = [ "ses:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
    statement {
      actions = [ "sns:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
    statement {
      actions = [ "logs:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
    statement {
      actions = [ "states:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
}

data "aws_iam_policy_document" "cuddle_serverless_sfn" {
    statement {
      actions = [ "lambda:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
    statement {
      actions = [ "sns:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
    statement {
      actions = [ "logs:*" ]
      effect = "Allow"
      resources = [ "*" ]
    }
}

resource "aws_iam_role" "cuddle_serverless_lambda" {
  assume_role_policy = data.aws_iam_policy_document.cuddle_serverless_assume.json
  name = "ilyass-lab-serverless-lambda"
}

resource "aws_iam_role_policy" "cuddle_serverless_lambda" {
  role = aws_iam_role.cuddle_serverless_lambda.id
  policy = data.aws_iam_policy_document.cuddle_serverless_lambda.json
}


resource "aws_iam_role" "cuddle_serverless_sfn" {
  assume_role_policy = data.aws_iam_policy_document.cuddle_serverless_assume.json
  name = "ilyass-lab-serverless-sfn"
}

resource "aws_iam_role_policy" "cuddle_serverless_sfn" {
  role = aws_iam_role.cuddle_serverless_sfn.id
  policy = data.aws_iam_policy_document.cuddle_serverless_sfn.json
}