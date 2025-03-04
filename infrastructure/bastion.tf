resource "aws_instance" "bastion" {
  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  # constrain to number of private subnets
  subnet_id                   = module.vpc.public_subnet_ids[0]
  user_data_replace_on_change = true

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-bastion"
}

resource "aws_security_group_rule" "allow_ssh_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "allow_egress_bastion" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}
