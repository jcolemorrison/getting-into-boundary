output "vpc_id" {
  value       = module.vpc.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "List of private subnet IDs"
}

output "aws_lb_controller_role_arn" {
  value       = aws_iam_role.aws_lb_controller.arn
  description = "ARN of the IAM role for the AWS Load Balancer Controller"
}

output "pod_cloudwatch_logging_arn" {
  value       = aws_iam_role.fluent_bit.arn
  description = "ARN of the IAM role for Fluent Bit logging"
}

output "pod_cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.pod_logs.name
  description = "Name of the CloudWatch log group for pod logs"
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "Name of the EKS cluster"
}

output "eks_node_group_name" {
  value       = aws_eks_node_group.node_group.node_group_name
  description = "Name of the EKS node group"
}

output "eks_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
  description = "ARN of the OIDC provider for the EKS cluster"
}

output "eks_cluster_api_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "API endpoint for the EKS cluster"
}

output "aws_rds_instance_endpoint" {
  value       = aws_db_instance.boundary.endpoint
  description = "Endpoint for the RDS instance"
}

output "ec2_kepair_name" {
  description = "The name of the EC2 key pair to use for remote access."
  value       = var.ec2_kepair_name
}

output "boundary_worker_auth_key_id" {
  description = "The ID of the Boundary worker authentication KMS key"
  value       = aws_kms_key.boundary_worker_auth.id
}

output "boundary_worker_auth_key_arn" {
  description = "The ARN of the Boundary worker authentication KMS key"
  value       = aws_kms_key.boundary_worker_auth.arn
}

output "boundary_worker_security_group_id" {
  description = "The ID of the security group for the Boundary workers"
  value       = aws_security_group.boundary_worker.id
}

output "boundary_controller_private_ips" {
  description = "The private IP addresses of the Boundary controllers"
  value       = aws_instance.boundary_controller[*].private_ip
}

output "boundary_controller_lb_dns" {
  description = "The public DNS name of the Boundary controller load balancer.  This is the boundary address used in other workspaces."
  value       = aws_lb.boundary_controller.dns_name
}

output "boundary_hosts_foo_private_ips" {
  description = "The private IP addresses of the Boundary foo host instances"
  value       = aws_instance.boundary_static_hosts_foo[*].private_ip
}

output "boundary_hosts_bar_private_ips" {
  description = "The private IP addresses of the Boundary bar host instances"
  value       = aws_instance.boundary_static_hosts_bar[*].private_ip
}

output "hcp_vault_private_endpoint" {
  value       = hcp_vault_cluster.main.vault_private_endpoint_url
  description = "Private endpoint for the HCP Vault cluster"
}

output "hcp_vault_public_endpoint" {
  value       = hcp_vault_cluster.main.vault_public_endpoint_url
  description = "Public endpoint for the HCP Vault cluster"
}

output "hcp_vault_cluster_bootstrap_token" {
  value       = hcp_vault_cluster_admin_token.bootstrap.token
  description = "Bootstrap token for the HCP Vault cluster"
  sensitive   = true
}

output "hcp_vault_namespace" {
  value       = hcp_vault_cluster.main.namespace
  description = "value of the namespace for the HCP Vault cluster"
}

output "database_url" {
  value = aws_db_instance.database.address
}

output "database_name" {
  value = aws_db_instance.database.db_name
}

output "database_username" {
  value = aws_db_instance.database.username
}

output "database_password" {
  value     = aws_db_instance.database.password
  sensitive = true
}

output "hcp_boundary_endpoint" {
  value = hcp_boundary_cluster.main.cluster_url
}

output "hcp_boundary_username" {
  value = hcp_boundary_cluster.main.username
}

output "hcp_boundary_password" {
  value     = hcp_boundary_cluster.main.password
  sensitive = true
}