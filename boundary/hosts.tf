# Dynamic Host Catalog - setup with credentials to access AWS and find EKS nodes
resource "boundary_host_catalog_plugin" "eks_nodes" {
  name            = "${var.project_name}-catalog"
  description     = "${var.project_name} plugin for ${var.aws_default_region}"
  scope_id        = "global"
  plugin_name     = "aws"

  attributes_json = jsonencode({ 
    region                      = var.aws_default_region
    disable_credential_rotation = true
  })

  secrets_json = jsonencode({
    access_key_id     = var.boundary_iam_user_access_key_id
    secret_access_key = var.boundary_iam_user_secret_access_key
  })
}

# Logic to grab the private IPs of the EKS nodes
data "aws_instances" "boundary_eks_instances" {
  instance_tags = {
    "eks:nodegroup-name" = var.eks_node_group_name
    "eks:cluster-name"   = var.eks_cluster_name
  }
}

data "aws_instance" "boundary_eks_instance" {
  for_each = toset(data.aws_instances.boundary_eks_instances.ids)
  instance_id = each.key
}

locals {
  instance_private_ips = { for id, instance in data.aws_instance.boundary_eks_instance : id => instance.private_ip }
}

resource "boundary_host_set_plugin" "eks_nodes" {
  name            = "${var.project_name}-eks-nodes"
  host_catalog_id = boundary_host_catalog_plugin.eks_nodes.id
  preferred_endpoints = [for _, ip in local.instance_private_ips : "cidr:${ip}/32"]
  attributes_json = jsonencode({
    filters = [
      "tag:eks:nodegroup-name=${var.eks_node_group_name}",
      "tag:eks:cluster-name=${var.eks_cluster_name}"
    ]
  })
}
