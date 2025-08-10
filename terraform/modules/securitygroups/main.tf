resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow http/https traffic in"
  vpc_id      = aws_vpc.network.id
}

resource "aws_security_group_rule" "allow_https_in_alb" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
  protocol = "tcp"
  description = "HTTPS from internet"
}

resource "aws_security_group_rule" "allow_http_in_alb" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
  protocol = "tcp"
  description = "HTTP from internet"
}

resource "aws_security_group_rule" "alb_out_to_ecs" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "ALB to ECS on app port"
}


resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  vpc_id      = aws_vpc.network.id
  description = "Allow from ALB into ECS"
}


resource "aws_security_group_rule" "allow_alb_sg_in_ecs" {
  type = "ingress"
  security_group_id = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.alb.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  description              = "Allow app traffic from ALB SG"
}

resource "aws_security_group_rule" "allow_all_out_ecs" {
  type              = "egress"
  security_group_id = aws_security_group.ecs.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allowing all traffic out"
  # Route table will direct through NAT
}