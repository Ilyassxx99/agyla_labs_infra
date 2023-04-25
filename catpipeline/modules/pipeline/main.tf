resource "aws_codecommit_repository" "ilyass_cicd_lab" {
  repository_name = "catpipelineIlyass"
  description = "Repository for CICD lab"
}

resource "aws_ecr_repository" "ilyass-cicd-lab" {
  name = "catpipeline"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}


data "aws_ssm_parameter" "catpipeline_github_token" {
  name = var.github_access_token_ssm
}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

resource "aws_codebuild_source_credential" "catpipeline_github_token" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.catpipeline_github_token.value
}

resource "aws_codebuild_project" "catpipeline" {
  name          = "ilyass-catpipeline"
  description   = "CodeBuild for catpipeline project"
  build_timeout = "5"
  service_role  = var.catpipeline_role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.ilyass-cicd-lab.name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ilyass-catpipeline-cicd"
      stream_name = "catpipeline"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  
  /* source {
    type            = "GITHUB"
    location        = "https://github.com/Ilyassxx99/aws-devops-cicd.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  } */
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "ilyass-catpipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.codepipeline.id
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
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*",
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
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*",
    ]
  }
}

resource "aws_codestarconnections_connection" "catpipeline" {
  name          = "catpipeline-ilyass"
  provider_type = "GitHub"
}

resource "aws_codedeploy_app" "catpipeline" {
  compute_platform = "ECS"
  name             = "ilyass-catpipeline"
}

resource "aws_codedeploy_deployment_group" "catpipeline" {
  app_name = aws_codedeploy_app.catpipeline.name
  deployment_group_name = "ilyass-catpipeline-group"
  service_role_arn = var.catpipeline_deploy_role
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.catpipeline_ecs_cluster
    service_name = var.catpipeline_ecs_service
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.catpipeline_lb_listener_arn]
      }

      target_group {
        name = var.catpipeline_tg_A_name
      }

      target_group {
        name = var.catpipeline_tg_B_name
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "catpipeline-ilyass"
  role_arn = var.catpipeline_role

  artifact_store {
    location = aws_s3_bucket.codepipeline.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.catpipeline.arn
        FullRepositoryId = "Ilyassxx99/aws-devops-cicd"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "ilyass-catpipeline"
      }
    }
  }

/*   stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ClusterName = var.catpipeline_ecs_cluster
        ServiceName = var.catpipeline_ecs_service
        FileName    = "imagedefinitions.json"
      }
    }
  } */

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        AppSpecTemplateArtifact = "source_output"
        AppSpecTemplatePath = "appspec.yml"
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath = "task_definition.json"
        ApplicationName         = aws_codedeploy_app.catpipeline.name
        DeploymentGroupName     = aws_codedeploy_deployment_group.catpipeline.deployment_group_name
      }
    }
  }


}