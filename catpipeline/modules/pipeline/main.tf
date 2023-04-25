data "aws_ssm_parameter" "catpipeline_github_token" {
  name = var.github_access_token_ssm
}

data "aws_caller_identity" "current" {}

/* resource "aws_codebuild_source_credential" "catpipeline_github_token" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.catpipeline_github_token.value
} */

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
    privileged_mode             = true
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
      value = var.catpipeline_ecr_name
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

resource "aws_codestarconnections_connection" "catpipeline" {
  name          = "catpipeline-ilyass"
  provider_type = "GitHub"
}

resource "aws_codedeploy_app" "catpipeline" {
  compute_platform = "ECS"
  name             = "ilyass-catpipeline"
}

resource "aws_codedeploy_deployment_group" "catpipeline" {
  app_name               = aws_codedeploy_app.catpipeline.name
  deployment_group_name  = "ilyass-catpipeline-group"
  service_role_arn       = var.catpipeline_deploy_role
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
  depends_on = [
    aws_codestarconnections_connection.catpipeline,
    aws_codedeploy_deployment_group,
  ]

  artifact_store {
    location = var.catpipeline_bucket_id
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
        FullRepositoryId = var.app_source_github_repo
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
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        AppSpecTemplateArtifact        = "source_output"
        AppSpecTemplatePath            = "appspec.yml"
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath     = "task_definition.json"
        ApplicationName                = aws_codedeploy_app.catpipeline.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.catpipeline.deployment_group_name
      }
    }
  }


}
