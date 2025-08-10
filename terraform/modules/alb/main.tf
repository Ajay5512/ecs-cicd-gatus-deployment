resource "aws_lb" "gatus_alb" {
  name               = "ecsalb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.alb.id]
  enable_deletion_protection = false
  idle_timeout               = 60
}

resource "aws_lb_target_group" "target_app" {
  name        = "tg-app"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.network.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
# redirecting http traffic into https port for security
  load_balancer_arn = aws_lb.gatus_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.gatus_alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06" # this is aws managed
  certificate_arn = aws_acm_certificate.acm.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_app.arn
  }
}