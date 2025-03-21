terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1.15"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
  default_tags {
    tags = var.aws_default_tags
  }
}

provider "boundary" {
  addr                   = "https://${local.boundary_address}:9200"
  auth_method_login_name = local.boundary_login_name
  auth_method_password   = local.boundary_login_pwd
  auth_method_id         = var.boundary_auth_method_id 
  tls_insecure = true
}

provider "vault" {
  address   = local.hcp_vault_public_endpoint
  token     = local.hcp_vault_cluster_bootstrap_token
  namespace = local.hcp_vault_namespace
}