# Worker that uses controller led authorization
resource "boundary_worker" "ctrl_led_worker" {
  scope_id    = "global"
  name        = "${var.project_name}-worker"
  description = "self managed worker with controller led auth"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "boundary_worker_ctrl_led" {
  # count = var.boundary_worker_count

  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_worker.id]

  # constrain to number of public subnets
  subnet_id = module.vpc.public_subnet_ids[0]

  user_data = templatefile("${path.module}/scripts/boundary-worker-ctrl-led.sh", {
    CONTROLLER_ADDRESSES                  = jsonencode(local.boundary_controller_private_ips)
    CONTROLLER_GENERATED_ACTIVATION_TOKEN = boundary_worker.ctrl_led_worker.controller_generated_activation_token
    WORKER_ID                             = boundary_worker.ctrl_led_worker.id
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-ctrl-led"
  }
}

# Worker that uses KMS led authorization
resource "aws_instance" "boundary_worker_kms_led" {
  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_worker.id]

  # constrain to number of public subnets
  subnet_id = module.vpc.public_subnet_ids[1]

  user_data = templatefile("${path.module}/scripts/boundary-worker-kms-led.sh", {
    CONTROLLER_ADDRESSES = jsonencode(local.boundary_controller_private_ips)
    KMS_WORKER_AUTH_KEY_ID = local.boundary_worker_auth_key_id
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-kms-led"
  }
}

# Worker that uses worker led authorization
resource "aws_instance" "boundary_worker_wkr_led" {
  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_worker.id]

  # constrain to number of public subnets
  subnet_id = module.vpc.public_subnet_ids[2]

  user_data = templatefile("${path.module}/scripts/boundary-worker-wkr-led.sh", {
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-wkr-led"
  }
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