data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = var.hcp_terraform_organization_name
    workspaces = {
      name = var.hcp_terraform_infrastructure_workspace_name
    }
  }
}

locals {
  aws_lb_controller_role_arn        = try(data.terraform_remote_state.infrastructure.outputs.aws_lb_controller_role_arn, var.aws_lb_controller_role_arn)
  pod_cloudwatch_log_group_name     = try(data.terraform_remote_state.infrastructure.outputs.pod_cloudwatch_log_group_name, var.pod_cloudwatch_log_group_name)
  pod_cloudwatch_logging_arn        = try(data.terraform_remote_state.infrastructure.outputs.pod_cloudwatch_logging_arn, var.pod_cloudwatch_logging_arn)
  eks_cluster_name                  = try(data.terraform_remote_state.infrastructure.outputs.eks_cluster_name, var.eks_cluster_name)
  eks_oidc_provider_arn             = try(data.terraform_remote_state.infrastructure.outputs.eks_oidc_provider_arn, var.eks_oidc_provider_arn)
  eks_cluster_api_endpoint          = try(data.terraform_remote_state.infrastructure.outputs.eks_cluster_api_endpoint, var.eks_cluster_api_endpoint)
}