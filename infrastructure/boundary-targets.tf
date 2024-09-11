resource "aws_instance" "boundary_sample_target" {
  count = var.boundary_sample_target_count

  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = false
  instance_type               = "t3.micro"
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_sample_target.id]

  # constrain to number of private subnets
  subnet_id = module.vpc.private_subnet_ids[count.index % 3]

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-target-${count.index}"
  }
}

resource "aws_security_group" "boundary_sample_target" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-sample-target"
}

resource "aws_security_group_rule" "allow_ssh_from_boundary_worker" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_worker.id
  security_group_id        = aws_security_group.boundary_sample_target.id
}

resource "aws_security_group_rule" "allow_egress_boundary_sample_target" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_sample_target.id
}