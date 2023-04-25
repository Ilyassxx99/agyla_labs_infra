data "aws_elb_service_account" "main" {}

resource "aws_ecr_repository" "ilyass-cicd-lab" {
  name                 = "catpipeline"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_s3_bucket" "catpipeline" {
  bucket        = "ilyass-catpipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "catpipeline" {
  bucket = aws_s3_bucket.catpipeline.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "catpipeline" {
  bucket = aws_s3_bucket.catpipeline.id
  acl    = "private"
  depends_on = [
    aws_s3_bucket_ownership_controls.catpipeline
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline" {
  bucket = aws_s3_bucket.catpipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.catpipeline.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.catpipeline.arn,
      "${aws_s3_bucket.catpipeline.arn}/*",
    ]
  }
  statement {
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
        "ec2.amazonaws.com",
        "codepipeline.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "codedeploy.amazonaws.com"
      ]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.catpipeline.arn,
      "${aws_s3_bucket.catpipeline.arn}/*",
    ]
  }
}