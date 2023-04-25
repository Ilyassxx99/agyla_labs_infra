
resource "aws_cloudwatch_log_group" "catpipeline_compute" {
  name = "ilyass-catpipeline-compute"
}

resource "aws_lb" "catpipeline" {
  name               = "catpipeline"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ecs_sg_id]
  subnets            = [
    var.ecs_subnet_primary_id,
    var.ecs_subnet_secondary_id
   ]

  enable_deletion_protection = false

  access_logs {
    bucket  = var.lb_logs_bucket_id
    prefix  = "catpipeline-lb"
    enabled = true
  }
}

resource "aws_lb_target_group" "catpipeline_A" {
  name        = "catpipeline-A-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  depends_on = [
    aws_lb.catpipeline
  ]
}

resource "aws_lb_target_group" "catpipeline_B" {
  name        = "catpipeline-B-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  depends_on = [
    aws_lb.catpipeline
  ]
}

resource "aws_lb_listener" "catpipeline" {
  load_balancer_arn = aws_lb.catpipeline.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on = [
    aws_lb_target_group.catpipeline_A
  ]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catpipeline_A.arn
  }
}


/* resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.catpipeline.arn
  target_id        = 
  port             = 80
  depends_on = [
    aws_lb_target_group.ip-example
  ]
} */

resource "aws_ecs_cluster" "catpipeline" {
  name = "ilyass-catpipeline-ecs"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.catpipeline_compute.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "catpipeline" {
  cluster_name = aws_ecs_cluster.catpipeline.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "catpipeline" {
  family = var.task_def_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn = var.ecs_task_role_arn
  container_definitions = jsonencode([
    {
      name      = "${var.container_name}"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 80
        }
      ]
    }
    ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
}

resource "aws_ecs_service" "catpipeline" {
  name            = "catpipelineservice"
  cluster         = aws_ecs_cluster.catpipeline.id
  task_definition = aws_ecs_task_definition.catpipeline.arn
  desired_count   = 2
  launch_type = "FARGATE"
  wait_for_steady_state = false

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [
    aws_lb.catpipeline,
    aws_ecs_cluster.catpipeline,
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.catpipeline_A.arn
    container_name   = "catpipeline"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    subnets = [var.ecs_subnet_primary_id]
    security_groups = [var.ecs_sg_id]
  }
}