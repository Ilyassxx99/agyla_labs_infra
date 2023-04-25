resource "aws_ses_email_identity" "cuddle_serverless" {
  email = var.sender_email
}

