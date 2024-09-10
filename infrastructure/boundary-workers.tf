resource "aws_instance" "boundary_worker" {
  count = var.boundary_worker_count

  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_worker.id]

  # constrain to number of public subnets
  subnet_id = module.vpc.public_subnet_ids[count.index % 3]

  user_data = templatefile("${path.module}/scripts/boundary-worker.sh", {
  })

  user_data_replace_on_change = true
}

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