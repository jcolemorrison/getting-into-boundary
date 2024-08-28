# Root CA
resource "tls_private_key" "boundary_key" {
  algorithm = "RSA"
  rsa_bits  = 2048 # must be 2048 to work with ACM
}

resource "tls_self_signed_cert" "boundary_cert" {
  private_key_pem   = tls_private_key.boundary_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name = "ca.boundary.controller"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "boundary" {
  private_key       = tls_private_key.boundary_key.private_key_pem
  certificate_body  = tls_self_signed_cert.boundary_cert.cert_pem
}