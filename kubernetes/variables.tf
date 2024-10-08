variable "project_name" {
  type        = string
  description = "The name of the project. Used for naming resources."
  default     = "getting-into-boundary-k8s"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags added to all AWS resources."
  default = {
    Project = "getting-into-boundary-k8s"
  }
}

variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "aws_lb_controller_version" {
  type        = string
  description = "The version of the AWS Load Balancer Controller."
  default     = "1.7.2"
}

variable "aws_lb_controller_role_arn" {
  type        = string
  description = "The ARN of the IAM role for the AWS Load Balancer Controller."
}

variable "pod_cloudwatch_log_group_name" {
  type        = string
  description = "The name of the CloudWatch log group for pod logs."
}

variable "pod_cloudwatch_logging_arn" {
  type        = string
  description = "The ARN of the IAM role for pod logging."
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC provider for the EKS cluster."
}

variable "eks_cluster_api_endpoint" {
  type        = string
  description = "The API endpoint for the EKS cluster."
}

# Below must be set in the workspace or via the CLI

variable "hcp_terraform_organization_name" {
  type        = string
  description = "The name of the Terraform organization."
}

variable "hcp_terraform_infrastructure_workspace_name" {
  type        = string
  description = "The name of the infrastructure workspace."
}