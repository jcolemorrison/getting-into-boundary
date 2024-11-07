variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags added to all AWS resources."
  default = {
    Project = "getting-into-boundary"
  }
}

variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "The name of the project. Used for naming resources."
  default     = "getting-into-boundary"
}

variable "ec2_kepair_name" {
  type        = string
  description = "The name of the EC2 key pair to use for remote access."
}

variable "boundary_address" {
  type        = string
  description = "The address of the Boundary cluster endpoint."
  default     = null
}

variable "boundary_login_name" {
  type        = string
  description = "The login name for the Boundary cluster."
  default     = null
}

variable "boundary_login_pwd" {
  type        = string
  description = "The login password for the Boundary cluster."
  sensitive   = true
  default     = null
}

variable "boundary_admin_enable_ssh" {
  type        = bool
  description = "Enable SSH access to the Boundary controllers."
  default     = true
}

variable "boundary_admin_allowed_ssh_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH into the Boundary controllers and workers."
  default     = ["0.0.0.0/0"]
}

variable "boundary_worker_allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the Boundary workers."
  default     = ["0.0.0.0/0"]
}

variable "boundary_controller_private_ips" {
  type        = list(string)
  description = "The private IP addresses of the Boundary controllers."
  default     = null
}

variable "boundary_worker_auth_key_id" {
  type        = string
  description = "The ID of the Boundary worker authentication KMS key."
  default = null
}

variable "boundary_worker_auth_key_arn" {
  type        = string
  description = "The ARN of the Boundary worker authentication KMS key."
  default = null
}

variable "boundary_worker_security_group_id" {
  type        = string
  description = "The ID of the security group for the Boundary workers."
  default = null
}

variable "hcp_terraform_organization_name" {
  type        = string
  description = "The name of the HCP Terraform organization."
}

variable "hcp_tf_global_infra_workspace_name" {
  type        = string
  description = "The name of the HCP Terraform infrastructure workspace."
}