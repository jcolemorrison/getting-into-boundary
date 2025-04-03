data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "boundary_controller" {
  count = var.boundary_controller_count

  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = false
  instance_type               = "r8g.medium"
  iam_instance_profile        = aws_iam_instance_profile.boundary_controller.name
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_controller.id]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = {
      Name    = "boundary-controller-${count.index}"
      Purpose = "boundary-audit-logs"
    }

    volume_size = 32
    volume_type = "gp2"
  }

  # constrain to number of private subnets
  subnet_id = module.vpc.private_subnet_ids[count.index % 3]

  user_data = templatefile("${path.module}/scripts/boundary-controller.sh", {
    INDEX                  = count.index
    DB_USERNAME            = var.boundary_db_username
    DB_PASSWORD            = random_password.boundary_db_password.result
    DB_ENDPOINT            = aws_db_instance.boundary.endpoint # has port included
    DB_NAME                = aws_db_instance.boundary.db_name
    KMS_WORKER_AUTH_KEY_ID = aws_kms_key.boundary_worker_auth.id
    KMS_RECOVERY_KEY_ID    = aws_kms_key.boundary_recovery.id
    KMS_ROOT_KEY_ID        = aws_kms_key.boundary_root.id
    SERVER_KEY             = tls_private_key.boundary_key.private_key_pem
    SERVER_CERT            = tls_self_signed_cert.boundary_cert.cert_pem
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-controller-${count.index}"
  }
}

resource "aws_security_group" "boundary_controller" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-controller"
}

resource "aws_security_group_rule" "allow_9200_boundary_controller" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_controller_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_3000_boundary_controller" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_controller_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_9203_boundary_controller_health" {
  type                     = "ingress"
  from_port                = 9203
  to_port                  = 9203
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_controller_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_9201_boundary_controller" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_9201_boundary_workers" {
  type                     = "ingress"
  from_port                = 9201
  to_port                  = 9201
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_worker.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_ssh_boundary_controller" {
  count             = var.boundary_admin_enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.boundary_admin_allowed_ssh_cidr_blocks
  security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_egress_boundary_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_controller.id
}
