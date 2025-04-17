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