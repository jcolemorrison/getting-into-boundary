resource "aws_iam_role" "boundary_controller" {
  name = "${var.project_name}-boundary-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "boundary_controller" {
  name = "${var.project_name}-boundary-controller-profile"
  role = aws_iam_role.boundary_controller.name
}

resource "aws_iam_role_policy" "boundary" {
  name = "${var.project_name}-boundary"
  role = aws_iam_role.boundary_controller.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.boundary_root.arn}",
      "${aws_kms_key.boundary_worker_auth.arn}",
      "${aws_kms_key.boundary_recovery.arn}"
    ]
  }
}
EOF
}

resource "aws_iam_role" "boundary_worker" {
  name = "${var.project_name}-boundary-worker"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "boundary_worker" {
  name = "${var.project_name}-boundary-worker-profile"
  role = aws_iam_role.boundary_worker.name
}