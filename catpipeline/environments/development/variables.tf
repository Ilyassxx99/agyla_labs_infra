variable "github_access_token" {
  description = "Github personal access token"
  sensitive = true
}

variable "aws_ami_id" {
  description = "Id of AWS AMI"
  default = "ami-02396cdd13e9a1257"
}

variable "container_name" {
  description = "Name of ECS Container"
  default = "catpipeline"
}

variable "container_port" {
  description = "Name of ECS Container"
  default = 80
  type = number
}

variable "task_def_name" {
  description = "Id of AWS AMI"
  default = "catpipelinedemo"
}

variable "app_source_path" {
  description = "Directory Path of Source App Code"
  default = "/Users/agyla/Labs/DevOps-CICD/repos/catpipeline"
}


variable "app_source_github_repo" {
  description = "GitHub Repository of Source App Code"
  default = "https://github.com/Ilyassxx99/catpipeline-test.git"
}