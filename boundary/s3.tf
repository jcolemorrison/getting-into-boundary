resource "aws_s3_bucket" "boundary_session_recording" {
  bucket_prefix = "${var.project_name}-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "boundary_session_recording" {
  bucket = aws_s3_bucket.boundary_session_recording.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "boundary_session_recording" {
  description             = "Boundary session recording bucket KMS key"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "boundary_session_recording" {
  bucket = aws_s3_bucket.boundary_session_recording.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.boundary_session_recording.arn
      sse_algorithm     = "aws:kms"
    }
  }
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