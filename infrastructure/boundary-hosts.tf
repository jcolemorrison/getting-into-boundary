resource "aws_instance" "boundary_static_hosts" {
  count = 2

  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = false
  instance_type               = "t3.micro"
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_sample_target.id]

  # constrain to number of private subnets
  subnet_id = module.vpc.private_subnet_ids[count.index % 3]

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-static-host-${count.index}"
  }
}

resource "aws_security_group" "boundary_static_host" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-static-host"
}

resource "aws_security_group_rule" "allow_ssh_from_boundary_worker_to_static_host" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = [var.remote_access_cidr_block]
  security_group_id        = aws_security_group.boundary_static_host.id
}

resource "aws_security_group_rule" "allow_egress_boundary_static_host" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_static_host.id
}