# VPC
module "vpc" {
  source     = "../modules/vpc"
  cidr_block = var.vpc_cidr_block
  name       = var.project_name
}

resource "aws_route" "tgw_route_private" {
  destination_cidr_block = var.hvn_cidr_block
  route_table_id         = module.vpc.private_route_table_id
  transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.main_tgw ]
}

resource "aws_route" "tgw_route_public" {
  destination_cidr_block = var.hvn_cidr_block
  route_table_id         = module.vpc.public_route_table_id
  transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.main_tgw ]
}