variable "project_name" {
  type        = string
  description = "The name of the project.  Used for naming resources."
  default     = "getting-into-boundary-services"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags added to all AWS resources."
  default = {
    Project = "getting-into-boundary-services"
  }
}

variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "default_container_image" {
  type        = string
  description = "Default service container image"
  default     = "nicholasjackson/fake-service:v0.26.0"
}

variable "ui_service_name" {
  type        = string
  description = "The name of the UI service. Used for namespace and name."
  default     = "ui"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet IDs."
}

### Must be set in the workspace or via the CLI

variable "hcp_terraform_organization_name" {
  type        = string
  description = "The name of the Terraform organization."
}

variable "hcp_terraform_infrastructure_workspace_name" {
  type        = string
  description = "The name of the infrastructure workspace."
}