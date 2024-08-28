locals {
  cidr_prefix = split("/", module.vpc.private_subnets_cidr_blocks[0])[1]
  host_numbers = range(pow(2, 32 - local.cidr_prefix))

  # all IPs within the private subnets
  ip_addresses = flatten([for subnet in module.vpc.private_subnets_cidr_blocks : [for host_number in local.host_numbers : cidrhost(subnet, host_number)]])
}

# Root CA
resource "tls_private_key" "boundary_ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048 # must be 2048 to work with ACM
}

resource "tls_self_signed_cert" "boundary_ca_cert" {
  private_key_pem   = tls_private_key.boundary_ca_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name = "ca.boundary.controller"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

# Server Certificate
resource "tls_private_key" "boundary_server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048 # must be 2048 to work with ACM
}

## Public Server Cert
resource "tls_cert_request" "boundary_server_cert" {
  private_key_pem = tls_private_key.boundary_server_key.private_key_pem

  subject {
    common_name = "ca.boundary.controller"
  }

  dns_names = [
    "ca.boundary.controller",
    "localhost"
  ]

  ip_addresses = concat(
    ["127.0.0.1"],
    local.ip_addresses
  )
}

## Signed Public Server Certificate
resource "tls_locally_signed_cert" "boundary_server_signed_cert" {
  cert_request_pem = tls_cert_request.boundary_server_cert.cert_request_pem

  ca_private_key_pem = tls_private_key.boundary_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.boundary_ca_cert.cert_pem

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]

  validity_period_hours = 8760
}

resource "aws_acm_certificate" "boundary" {
  private_key       = tls_private_key.boundary_server_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.boundary_server_signed_cert.cert_pem
  certificate_chain = tls_self_signed_cert.boundary_ca_cert.cert_pem
}