# Dynamic Host Catalog - setup with credentials to access AWS and find EKS nodes
resource "boundary_host_catalog_plugin" "eks_nodes" {
  name            = "${var.project_name}-catalog"
  description     = "${var.project_name} plugin for ${var.aws_default_region}"
  scope_id        = boundary_scope.gib_project.id
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
    "eks:nodegroup-name" = local.eks_node_group_name
    "eks:cluster-name"   = local.eks_cluster_name
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
      "tag:eks:nodegroup-name=${local.eks_node_group_name}",
      "tag:eks:cluster-name=${local.eks_cluster_name}"
    ]
  })
}

# Static Hosts
resource "boundary_host_catalog_static" "foo" {
  name        = "${var.project_name}-static-catalog-foo"
  description = "Static host catalog for foo project"
  scope_id    = boundary_scope.gib_project_foo.id
}

resource "boundary_host_static" "foo" {
  count           = length(local.boundary_hosts_foo_private_ips)
  name            = "${var.project_name}-static-foo-${count.index}"
  description     = "Static host for foo project"
  address         = local.boundary_hosts_foo_private_ips[count.index]
  host_catalog_id = boundary_host_catalog_static.foo.id
}

resource "boundary_host_set_static" "foo" {
  name           = "${var.project_name}-static-foo"
  host_catalog_id = boundary_host_catalog_static.example.id
  host_ids        = boundary_host_static.foo[*].id
}

resource "boundary_host_catalog_static" "bar" {
  name        = "${var.project_name}-static-catalog-bar"
  description = "Static host catalog for bar project"
  scope_id    = boundary_scope.gib_project_bar.id
}

resource "boundary_host_static" "bar" {
  count           = length(local.boundary_hosts_bar_private_ips)
  name            = "${var.project_name}-static-bar-${count.index}"
  description     = "Static host for bar project"
  address         = local.boundary_hosts_bar_private_ips[count.index]
  host_catalog_id = boundary_host_catalog_static.bar.id
}

resource "boundary_host_set_static" "bar" {
  name           = "${var.project_name}-static-bar"
  host_catalog_id = boundary_host_catalog_static.example.id
  host_ids        = boundary_host_static.bar[*].id
}