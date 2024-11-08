locals {
  boundary_address              = try(data.terraform_remote_state.infrastructure.outputs.boundary_controller_lb_dns, var.boundary_address)
  boundary_login_name           = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_name, var.boundary_login_name)
  boundary_login_pwd            = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_pwd, var.boundary_login_pwd)
  boundary_controller_private_ips = try(data.terraform_remote_state.infrastructure.outputs.boundary_controller_private_ips, var.boundary_controller_private_ips)
  boundary_worker_auth_key_id = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_id, var.boundary_worker_auth_key_id)
  boundary_worker_auth_key_arn = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_arn, var.boundary_worker_auth_key_arn)
  boundary_worker_security_group_id = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_security_group_id, var.boundary_worker_security_group_id)
  ec2_kepair_name = try(data.terraform_remote_state.infrastructure.outputs.ec2_kepair_name, var.ec2_kepair_name)
  public_subnet_ids = try(data.terraform_remote_state.infrastructure.outputs.public_subnet_ids, var.public_subnet_ids)
  private_subnet_ids = try(data.terraform_remote_state.infrastructure.outputs.private_subnet_ids, var.private_subnet_ids)
  eks_node_group_name = try(data.terraform_remote_state.infrastructure.outputs.eks_node_group_name, var.eks_node_group_name)
  eks_cluster_name = try(data.terraform_remote_state.infrastructure.outputs.eks_cluster_name, var.eks_cluster_name)
}