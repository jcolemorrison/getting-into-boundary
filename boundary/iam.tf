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

resource "aws_iam_instance_profile" "boundary_worker_profile" {
  name = "${var.project_name}-boundary-worker-profile"
  role = aws_iam_role.boundary_worker.name
}

resource "aws_iam_role_policy" "boundary_worker_kms_auth" {
  name = "${var.project_name}-boundary"
  role = aws_iam_role.boundary_worker.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ],
    "Resource": [
      "${local.boundary_worker_auth_key_arn}"
    ]
  }
}
EOF
}