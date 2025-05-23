locals {
  boundary_address                  = try(data.terraform_remote_state.infrastructure.outputs.boundary_controller_lb_dns, var.boundary_address)
  boundary_login_name               = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_name, var.boundary_login_name)
  boundary_login_pwd                = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_pwd, var.boundary_login_pwd)
  boundary_controller_private_ips   = try(data.terraform_remote_state.infrastructure.outputs.boundary_controller_private_ips, var.boundary_controller_private_ips)
  boundary_hosts_foo_private_ips    = try(data.terraform_remote_state.infrastructure.outputs.boundary_hosts_foo_private_ips, var.boundary_hosts_foo_private_ips)
  boundary_hosts_bar_private_ips    = try(data.terraform_remote_state.infrastructure.outputs.boundary_hosts_bar_private_ips, var.boundary_hosts_bar_private_ips)
  boundary_worker_auth_key_id       = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_id, var.boundary_worker_auth_key_id)
  boundary_worker_auth_key_arn      = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_arn, var.boundary_worker_auth_key_arn)
  boundary_worker_security_group_id = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_security_group_id, var.boundary_worker_security_group_id)
  ec2_kepair_name                   = try(data.terraform_remote_state.infrastructure.outputs.ec2_kepair_name, var.ec2_kepair_name)
  public_subnet_ids                 = try(data.terraform_remote_state.infrastructure.outputs.public_subnet_ids, var.public_subnet_ids)
  private_subnet_ids                = try(data.terraform_remote_state.infrastructure.outputs.private_subnet_ids, var.private_subnet_ids)
  eks_node_group_name               = try(data.terraform_remote_state.infrastructure.outputs.eks_node_group_name, var.eks_node_group_name)
  eks_cluster_name                  = try(data.terraform_remote_state.infrastructure.outputs.eks_cluster_name, var.eks_cluster_name)
  hcp_vault_public_endpoint         = try(data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_endpoint, var.hcp_vault_public_endpoint)
  hcp_vault_namespace               = try(data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace, var.hcp_vault_namespace)
  hcp_vault_cluster_bootstrap_token = try(data.terraform_remote_state.infrastructure.outputs.hcp_vault_cluster_bootstrap_token, var.hcp_vault_cluster_bootstrap_token)
  database_url                      = try(data.terraform_remote_state.infrastructure.outputs.database_url, var.database_url)
  database_name                     = try(data.terraform_remote_state.infrastructure.outputs.database_name, var.database_name)
  database_username                 = try(data.terraform_remote_state.infrastructure.outputs.database_username, var.database_username)
  database_password                 = try(data.terraform_remote_state.infrastructure.outputs.database_password, var.database_password)
  hcp_boundary_address              = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_endpoint
  hcp_boundary_username             = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_username
  hcp_boundary_password             = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_password
}