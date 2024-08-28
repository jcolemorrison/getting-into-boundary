resource "aws_lb" "boundary_controller" {
  name_prefix        = "boundary-controller-"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.boundary_controller_lb.id]
  subnets            = module.vpc.public_subnets_ids
  idle_timeout       = 60
}

resource "aws_lb_target_group" "boundary_controller" {
  name_prefix          = "boundary-controller-"
  port                 = 9200
  protocol             = "TLS"
  vpc_id               = module.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  health_check {
    enabled             = false # change after after configured
    interval            = 30
    path                = "/health"
    protocol            = "TLS"
    port                = 9203 # boundary health port
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "boundary_controller_lb_tcp_80" {
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "boundary_controller_lb_tls_443" {
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.boundary.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_controller.arn
  }
}

resource "aws_security_group" "boundary_controller_lb" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-controller-lb"
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_80" {
  security_group_id = aws_security_group.boundary_controller_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTP traffic."
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_443" {
  security_group_id = aws_security_group.boundary_controller_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTPS traffic."
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_outbound" {
  security_group_id = aws_security_group.boundary_controller_lb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow any outbound traffic."
}