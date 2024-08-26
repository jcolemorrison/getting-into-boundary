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

variable "hcp_boundary_host_plugin_role_arn" {
  type        = string
  description = "ARN of the IAM role for the HCP Boundary host plugin"
}