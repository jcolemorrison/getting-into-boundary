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

data "aws_iam_policy_document" "boundary_session_recording" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = ["${aws_s3_bucket.boundary_session_recording.arn}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.boundary_session_recording.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.boundary_session_recording.arn]
  }
}

resource "aws_iam_policy" "boundary_session_recording" {
  name_prefix = "${var.project_name}-sessions-"
  description = "Policy for Boundary session recording bucket"
  policy      = data.aws_iam_policy_document.boundary_session_recording.json
}

resource "aws_iam_role_policy_attachment" "boundary_session_recording" {
  role       = aws_iam_role.boundary_worker.name
  policy_arn = aws_iam_policy.boundary_session_recording.arn
}