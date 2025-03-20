resource "hcp_hvn" "main" {
  hvn_id         = "${var.project_name}-hvn"
  cloud_provider = "aws"
  region         = var.aws_default_region
  cidr_block     = var.hvn_cidr_block
}

resource "aws_ram_principal_association" "main_tgw_to_hcp" {
  resource_share_arn = aws_ram_resource_share.main_tgw.arn
  principal          = hcp_hvn.main.provider_account_id
}

resource "hcp_aws_transit_gateway_attachment" "main_tgw" {
  hvn_id                        = hcp_hvn.main.hvn_id
  transit_gateway_attachment_id = "${var.project_name}-hvn"
  transit_gateway_id            = aws_ec2_transit_gateway.main_tgw.id
  resource_share_arn            = aws_ram_resource_share.main_tgw.arn

  depends_on = [
    aws_ram_principal_association.main_tgw_to_hcp,
    aws_ram_resource_association.main_tgw
  ]
}

resource "hcp_hvn_route" "route" {
  hvn_link         = hcp_hvn.main.self_link
  hvn_route_id     = "hvn-to-tgw-attachment"
  destination_cidr = var.vpc_cidr_block
  target_link      = hcp_aws_transit_gateway_attachment.main_tgw.self_link
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "main" {
  transit_gateway_attachment_id = hcp_aws_transit_gateway_attachment.main_tgw.provider_transit_gateway_attachment_id
}

import {
  to = aws_ec2_transit_gateway_vpc_attachment_accepter.main
  id = "tgw-attach-0910cf749c22cd261"
}