data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "gatus" {
  name              = "/ecs/gatus"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "gatus" {
  name = "gatus-cluster"
}

resource "aws_ecs_task_definition" "gatus" {
  family                   = "gatus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "gatus"
      image = var.ecr_image
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.gatus.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "gatus" {
  name             = "gatus-svc"
  cluster          = aws_ecs_cluster.gatus.id
  task_definition  = aws_ecs_task_definition.gatus.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  propagate_tags   = "SERVICE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "gatus"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_ecs_task_definition.gatus]
  
  lifecycle {
    create_before_destroy = false
  }
}
