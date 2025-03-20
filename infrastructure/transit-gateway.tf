resource "aws_ec2_transit_gateway" "main_tgw" {
  description = "transit gateway for ${var.project_name} in ${var.aws_default_region}"

  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  multicast_support               = "disable"
  transit_gateway_cidr_blocks     = [var.tgw_cidr_block]

  tags = { "Name" = "${var.project_name}-tgw" }
}

resource "aws_ram_resource_share" "main_tgw" {
  name                      = "${var.aws_default_region}-tgw"
  allow_external_principals = true

  tags = { "Name" = "${var.project_name}-tgw-ram" }
}

resource "aws_ram_resource_association" "main_tgw" {
  resource_arn       = aws_ec2_transit_gateway.main_tgw.arn
  resource_share_arn = aws_ram_resource_share.main_tgw.arn
}
