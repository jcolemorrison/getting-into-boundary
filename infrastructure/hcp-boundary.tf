resource "random_password" "boundary" {
  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 1
}

resource "hcp_boundary_cluster" "main" {
  cluster_id = var.project_name
  username   = "admin"
  password   = random_password.boundary.result
  tier       = "plus"
}