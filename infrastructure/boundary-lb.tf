resource "aws_lb" "boundary_controller" {
  name_prefix        = "bctl-"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.boundary_controller_lb.id]
  subnets            = module.vpc.public_subnet_ids
  idle_timeout       = 60
}

resource "aws_lb_target_group" "boundary_controller" {
  name_prefix          = "bctl-"
  port                 = 9200
  protocol             = "TCP"
  vpc_id               = module.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  stickiness {
    enabled = false
    type    = "source_ip"
  }
}

resource "aws_lb_target_group_attachment" "controller" {
  count            = var.boundary_controller_count
  target_group_arn = aws_lb_target_group.boundary_controller.arn
  target_id        = aws_instance.boundary_controller[count.index].id
  port             = 9200
}

resource "aws_lb_listener" "boundary_controller_lb" {
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = 9200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_controller.arn
  }
}

resource "aws_lb_listener" "boundary_controller_lb_logout" {
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_controller.arn
  }
}

resource "aws_security_group" "boundary_controller_lb" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-controller-lb"
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_443" {
  security_group_id = aws_security_group.boundary_controller_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 9200
  to_port           = 9200
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTPS traffic."
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_443_logout" {
  security_group_id = aws_security_group.boundary_controller_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
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