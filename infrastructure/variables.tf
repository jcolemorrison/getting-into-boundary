variable "project_name" {
  type        = string
  description = "The name of the project. Used for naming resources."
  default     = "getting-into-boundary"
}

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

variable "vpc_cidr_block" {
  type        = string
  description = "Cidr block for the VPC."
  default     = "10.0.0.0/16"
}

variable "ec2_kepair_name" {
  type        = string
  description = "The name of the EC2 key pair to use for remote access."
}

variable "remote_access_cidr_block" {
  type        = string
  description = "CIDR block for remote access."
  default     = "0.0.0.0/0"
}

variable "eks_cluster_version" {
  type        = string
  description = "The version of Kubernetes for EKS to use."
  default     = "1.29"
}

# Boundary Variables

variable "boundary_controller_count" {
  type        = number
  description = "The number of Boundary controllers to deploy."
  default     = 3
}

variable "boundary_worker_count" {
  type        = number
  description = "The number of Boundary workers to deploy."
  default     = 3
}

variable "boundary_sample_target_count" {
  type        = number
  description = "The number of Boundary sample targets to deploy."
  default     = 2
}

variable "boundary_db_username" {
  type        = string
  description = "The username for the Boundary database."
  default     = "boundary"
}

variable "boundary_db_password" {
  type        = string
  description = "The password for the Boundary database."
  sensitive   = true
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