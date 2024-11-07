# Only security groups in this project.  Workers themselves are the `boundary` directory.

resource "aws_security_group" "boundary_worker" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-worker"
}

resource "aws_security_group_rule" "allow_9202_boundary_workers" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_9202_boundary_worker_users" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = var.boundary_worker_allowed_cidr_blocks
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_ssh_boundary_worker" {
  count             = var.boundary_admin_enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.boundary_admin_allowed_ssh_cidr_blocks
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_egress_boundary_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_worker.id
}