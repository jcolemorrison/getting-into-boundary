locals {
  boundary_address              = try(data.terraform_remote_state.infrastructure.outputs.boundary_address, var.boundary_address)
  boundary_login_name           = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_name, var.boundary_login_name)
  boundary_login_pwd            = try(data.terraform_remote_state.infrastructure.outputs.boundary_login_pwd, var.boundary_login_pwd)
  boundary_controller_private_ips = try(data.terraform_remote_state.infrastructure.outputs.boundary_controller_private_ips, var.boundary_controller_private_ips)
  boundary_worker_auth_key_id = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_id, var.boundary_worker_auth_key_id)
  boundary_worker_auth_key_arn = try(data.terraform_remote_state.infrastructure.outputs.boundary_worker_auth_key_arn, var.boundary_worker_auth_key_arn)
  ec2_kepair_name = try(data.terraform_remote_state.infrastructure.outputs.ec2_kepair_name, var.ec2_kepair_name)
}