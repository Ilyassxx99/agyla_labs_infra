resource "aws_ssm_parameter" "catpipeline_github_token" {
  name        = "ilyass-github-token"
  description = "Personal access token for Github private repos"
  type        = "SecureString"
  value       = var.github_access_token
}


data "aws_iam_policy_document" "assume_role_catpipeline" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
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
  }
}

data "aws_iam_policy_document" "catpipeline" {
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:*",
    ]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "catpipeline_deploy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "catpipeline" {
  name = "ilyass-catpipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_catpipeline.json
}

resource "aws_iam_role_policy" "catpipeline" {
  role = aws_iam_role.catpipeline.id
  policy = data.aws_iam_policy_document.catpipeline.json
}

resource "aws_iam_role" "catpipeline_deploy" {
  name = "ilyass-catpipeline-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_catpipeline.json
}

resource "aws_iam_policy_attachment" "catpipeline_deploy_attach" {
  name       = "catpipeline-deploy-attachment"
  roles      = [aws_iam_role.catpipeline_deploy.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


resource "aws_iam_instance_profile" "test_profile" {
  name = "ilyass_test_profile"
  role = aws_iam_role.catpipeline.name
}