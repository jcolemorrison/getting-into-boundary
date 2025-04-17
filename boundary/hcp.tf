resource "boundary_scope" "hcp" {
  provider                 = boundary.hcp
  scope_id                 = "global"
  name                     = "getting-into-hcp-boundary"
  description              = "Getting into HCP Boundary project scope"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_host_catalog_static" "hcp" {
  provider = boundary.hcp

  name        = "${var.project_name}-static-catalog"
  description = "Static host catalog for HCP Boundary project"
  scope_id    = boundary_scope.hcp.id
}

resource "boundary_host_static" "hcp" {
  provider = boundary.hcp

  count           = length(local.boundary_hosts_foo_private_ips)
  name            = "${var.project_name}-static-${count.index}"
  description     = "Static host for HCP Boundary project"
  address         = local.boundary_hosts_foo_private_ips[count.index]
  host_catalog_id = boundary_host_catalog_static.foo.id
}

resource "boundary_host_set_static" "hcp" {
  provider = boundary.hcp

  name            = "${var.project_name}-static"
  host_catalog_id = boundary_host_catalog_static.hcp.id
  host_ids        = boundary_host_static.hcp.*.id
}

resource "boundary_target" "hcp" {
  provider = boundary.hcp

  name            = "static_hosts"
  description     = "Targets for the static hosts in the HCP Boundary project"
  type            = "tcp"
  default_port    = "22"
  scope_id        = boundary_scope.hcp.id
  host_source_ids = [boundary_host_set_static.hcp.id]
}