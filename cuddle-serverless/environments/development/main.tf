terraform {
  backend "s3" {
    bucket = "ilyass-lab"
    key    = "tf-serverless-state"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "default"
    default_tags {
    tags = {
      Environment = "Development"
      Name        = "Ilyass-serverless-lab"
    }
  }
}

module "notification" {
  source = "../../modules/notification"
  sender_email = var.sender_email
}

module "monitoring" {
  source = "../../modules/monitoring"
}

module "security" {
  source = "../../modules/security"
}

module "compute" {
  source = "../../modules/compute"
  lambda_role_arn = module.security.serverless_lambda_role_arn
  sender_email = var.sender_email
  sfn_role_arn = module.security.serverless_sfn_role_arn
  cloudwatch_serverless_sfn_arn = module.monitoring.cloudwatch_serverless_sfn_arn
  depends_on = [
    module.monitoring,
    module.security,
  ]
}

module "api" {
  source = "../../modules/api"
  cloudwatch_serverless_access_arn = module.monitoring.cloudwatch_serverless_sfn_arn
  cloudwatch_serverless_logs_role_arn = module.security.serverless_lambda_role_arn
  serverless_lambda_api_arn = module.compute.api_lambda_arn
  serverless_lambda_api_invoke_arn = module.compute.api_lambda_invoke_arn
  serverless_lambda_api_name = module.compute.api_lambda_name
}

module "storage" {
  source = "../../modules/storage"
  api_gateway_invoke_url = module.api.serverless_api_invoke_url
}