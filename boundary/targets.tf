resource "boundary_target" "static_hosts_foo" {
  name            = "static_hosts_foo"
  description     = "Targets for the static hosts in the foo project"
  type            = "tcp"
  default_port    = "22"
  scope_id        = boundary_scope.gib_project_foo.id
  host_source_ids = [boundary_host_set_static.foo.id]
}

resource "boundary_target" "static_hosts_bar" {
  name            = "static_hosts_bar"
  description     = "Targets for the static hosts in the bar project"
  type            = "tcp"
  default_port    = "22"
  scope_id        = boundary_scope.gib_project_bar.id
  host_source_ids = [boundary_host_set_static.bar.id]
}