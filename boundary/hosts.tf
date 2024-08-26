# Dynamic Host Catalog - auto find EKS Nodes
resource "boundary_host_catalog_plugin" "aws_us_east_1" {
  name            = "getting-into-boundary-catalog"
  description     = "Getting into Boundary aws catalog plugin for us-east-1"
  scope_id        = boundary_scope.gib_project.id
  plugin_name     = "aws"

  attributes_json = jsonencode({ 
    region                      = "us-east-1"
    disable_credential_rotation = true
    role_arn                    = var.hcp_boundary_host_plugin_role_arn
  })

  secrets_json = jsonencode({})
}