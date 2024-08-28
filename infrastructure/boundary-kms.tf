resource "aws_kms_key" "boundary_root" {
  description             = "Boundary root key"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "boundary_worker_auth" {
  description             = "Boundary worker authentication key"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "boundary_recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 10
}