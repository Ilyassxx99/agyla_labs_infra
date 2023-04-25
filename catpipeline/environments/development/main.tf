terraform {
  backend "s3" {
    bucket = "ilyass-lab"
    key    = "tf-cicd-state"
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
      Name        = "Ilyass-cicd-lab"
    }
  }
  }

module "pipeline" {
  source = "../../modules/pipeline"
  # Pass environment-specific variables
  github_access_token_ssm = module.security.catpipeline_github_token_ssm_name
  catpipeline_role = module.security.catpipeline_role_arn
  catpipeline_deploy_role = module.security.catpipeline_deploy_role_arn
  catpipeline_ecs_cluster = module.compute.catpipeline_ecs_cluster
  catpipeline_ecs_service = module.compute.catpipeline_ecs_service
  catpipeline_tg_A_name = module.compute.catpipeline_tg_A_name
  catpipeline_tg_B_name = module.compute.catpipeline_tg_B_name
  catpipeline_lb_listener_arn = module.compute.catpipeline_lb_listener_arn
  depends_on = [
    module.network,
    module.security,
  ]
}

module "security" {
  source = "../../modules/security"
  github_access_token = var.github_access_token
}

module "network" {
  source = "../../modules/network"
}

module "compute" {
  source = "../../modules/compute"
  ecr_repo_url = module.pipeline.ecr_repo_url
  ecs_task_role_arn = module.security.catpipeline_role_arn
  ecs_sg_id = module.network.catpipeline_sg_id
  ecs_subnet_primary_id = module.network.catpipeline_subnet_primary_id
  ecs_subnet_secondary_id = module.network.catpipeline_subnet_secondary_id
  lb_logs_bucket_id = module.pipeline.catpipeline_bucket_id
  vpc_id = module.network.catpipeline_vpc_id
  container_name = var.container_name
  task_def_name = var.task_def_name
  container_port = var.container_port
  depends_on = [
    module.network,
    module.security,
  ]
}

data "aws_caller_identity" "current" {}

locals {
  task_definition_template_content = templatefile("task_definition_template.json", {
    container_name = "${var.container_name}"
    image_url = "${module.pipeline.ecr_repo_url}:latest"
    account_id                = "${data.aws_caller_identity.current.account_id}"
    your_ecs_task_execution_role = "${module.security.catpipeline_role_arn}"
  })
  appspec_content = templatefile("appspec_template.yml", {
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
    task_def_arn = "${module.compute.catpipeline_task_def_arn}"
  })
}

resource "null_resource" "generate_task_definition" {
  provisioner "local-exec" {
    command = "echo '${local.task_definition_template_content}' > ${var.app_source_path}/task_definition.json"
  }

  triggers = {
    task_definition_template_content = local.task_definition_template_content
  }
}

resource "null_resource" "generate_app_spec" {
  provisioner "local-exec" {
    command = "echo '${local.appspec_content}' > ${var.app_source_path}/appspec.yml"
  }

  triggers = {
    appspec_content = local.appspec_content
  }
}