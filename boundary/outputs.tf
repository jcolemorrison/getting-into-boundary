output "bucket_name" {
  value = aws_s3_bucket.boundary_session_recording.bucket
}

output "role_arn" {
  value = aws_iam_role.boundary_worker.arn
}