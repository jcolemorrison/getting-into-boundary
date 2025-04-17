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

  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [local.boundary_worker_security_group_id]

  # constrain to number of public subnets
  subnet_id = local.public_subnet_ids[0]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = {
      Name    = "boundary-worker-ctrl-led"
      Purpose = "boundary-session-recordings"
    }

    volume_size = 32
    volume_type = "gp2"
  }

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
  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [local.boundary_worker_security_group_id]

  # constrain to number of public subnets
  subnet_id = local.public_subnet_ids[1]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = {
      Name    = "boundary-worker-kms-led"
      Purpose = "boundary-session-recordings"
    }

    volume_size = 32
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/scripts/boundary-worker-kms-led.sh", {
    CONTROLLER_ADDRESSES   = jsonencode(local.boundary_controller_private_ips)
    KMS_WORKER_AUTH_KEY_ID = local.boundary_worker_auth_key_id
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-kms-led"
  }
}

# Worker that uses worker led authorization
resource "aws_instance" "boundary_worker_wkr_led" {
  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [local.boundary_worker_security_group_id]

  # constrain to number of public subnets
  subnet_id = local.public_subnet_ids[2]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = {
      Name    = "boundary-worker-wkr-led"
      Purpose = "boundary-session-recordings"
    }

    volume_size = 32
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/scripts/boundary-worker-wkr-led.sh", {
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-wkr-led"
  }
}

# Worker that connects to HCP Boundary
resource "aws_instance" "boundary_worker_hcp" {
  ami                         = var.boundary_ami != "" ? var.boundary_ami : data.aws_ssm_parameter.al2023.value
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_profile.name
  key_name                    = local.ec2_kepair_name
  vpc_security_group_ids      = [local.boundary_worker_security_group_id]

  # constrain to number of public subnets
  subnet_id = local.public_subnet_ids[0]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = {
      Name    = "boundary-worker-hcp"
      Purpose = "boundary-session-recordings"
    }

    volume_size = 32
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/scripts/boundary-worker-hcp.sh", {
    HCP_BOUNDARY_CLUSTER_ID = split(replace(local.boundary_address, "https://", ""), ".").0
  })

  user_data_replace_on_change = true

  tags = {
    Name = "boundary-worker-hcp"
  }
}
