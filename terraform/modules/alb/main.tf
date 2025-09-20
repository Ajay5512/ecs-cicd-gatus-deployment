resource "aws_lb" "gatus_alb" {
  name                       = "ecsalb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.public_subnet_ids
  security_groups            = [var.alb_sg_id]
  enable_deletion_protection = false
  idle_timeout               = 60
  
  tags = {
    Name = "gatus-alb"
  }
}

resource "aws_lb_target_group" "target_app" {
  name        = "tg-app"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "gatus-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.gatus_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.gatus_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_app.arn
  }
}
