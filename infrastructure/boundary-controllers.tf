data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "boundary_controller" {
  count                       = var.boundary_controller_count

  ami                         = data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_controller.name
  key_name                    = var.ec2_kepair_name
  vpc_security_group_ids      = [aws_security_group.boundary_worker.id]

  # constrain to number of private subnets
  subnet_id                   = module.vpc.private_subnet_ids[count.index % 3]

  user_data = templatefile("${path.module}/scripts/boundary-controller.sh", {
    INDEX                   = count.index
    DB_USERNAME             = var.boundary_db_username
    DB_PASSWORD             = var.boundary_db_password
    DB_ENDPOINT             = aws_db_instance.boundary.endpoint
    KMS_WORKER_AUTH_KEY_ID  = aws_kms_key.boundary_worker_auth.id
    KMS_RECOVERY_KEY_ID     = aws_kms_key.boundary_recovery.id
    KMS_ROOT_KEY_ID         = aws_kms_key.boundary_root.id
    SERVER_CA               = tls_self_signed_cert.boundary_ca_cert.cert_pem
    SERVER_PUBLIC_KEY       = tls_locally_signed_cert.boundary_server_signed_cert.cert_pem
    SERVER_PRIVATE_KEY      = tls_private_key.boundary_server_key.private_key_pem
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
  source_security_group_id = aws_security_group.boundary_controller_lb.id #TBD
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

resource "aws_security_group_rule" "allow_ssh_boundary_controller" {
  count             = var.boundary_controller_enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.boundary_controller_allowed_cidr_blocks
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