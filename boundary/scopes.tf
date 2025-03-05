# Scopes
resource "boundary_scope" "gib_org" {
  scope_id                 = "global"
  name                     = "getting-into-boundary"
  description              = "Getting into Boundary organization scope"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "gib_project" {
  scope_id                 = boundary_scope.gib_org.id
  name                     = "getting-into-boundary"
  description              = "Getting into Boundary project scope"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "gib_project_foo" {
  scope_id                 = boundary_scope.gib_org.id
  name                     = "getting-into-boundary-foo"
  description              = "Getting into Boundary project scope foo"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "gib_project_bar" {
  scope_id                 = boundary_scope.gib_org.id
  name                     = "getting-into-boundary"
  description              = "Getting into Boundary project scope bar"
  auto_create_default_role = true
  auto_create_admin_role   = true
}