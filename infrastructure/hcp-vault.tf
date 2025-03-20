resource "hcp_vault_cluster" "main" {
  cluster_id      = var.project_name
  hvn_id          = hcp_hvn.main.hvn_id
  tier            = "plus_small"
  public_endpoint = true
}