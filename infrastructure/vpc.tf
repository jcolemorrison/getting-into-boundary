# VPC
module "vpc" {
  source     = "../modules/vpc"
  cidr_block = var.vpc_cidr_block
  name       = var.project_name
}

## Transit Gateway Attachments and Routing
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
}

resource "aws_route" "tgw_route_private" {
  destination_cidr_block = var.vpc_cidr_block
  route_table_id         = module.vpc.private_route_table_id
  transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.main ]
}