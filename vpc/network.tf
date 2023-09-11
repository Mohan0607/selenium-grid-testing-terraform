locals {
  vpc_name = var.resource_name_prefix
}
# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = local.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.bastion[0].id

  depends_on = [aws_internet_gateway.main]

}


resource "aws_eip" "nat_gw" {
  vpc = true
}
# Bastion Subnet
resource "aws_subnet" "bastion" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  count             = length(var.bastion_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.bastion_subnets_cidr_list[count.index]

  tags = {
    Name = join("-", [var.resource_name_prefix, "bastion", data.aws_availability_zones.available.names[count.index]])
  }
}


resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route" "bastion_internet" {
  route_table_id         = aws_route_table.bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "bastion" {
  count          = length(aws_subnet.bastion[*].id)
  subnet_id      = aws_subnet.bastion[count.index].id
  route_table_id = aws_route_table.bastion.id
}

# Private with Internet access
resource "aws_subnet" "private_egress" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  count             = length(var.private_egress_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_egress_subnets_cidr_list[count.index]
  tags = {
    Name = join("-", [var.resource_name_prefix, "private-egress", data.aws_availability_zones.available.names[count.index]])
  }
}


resource "aws_route_table" "private_egress" {
  vpc_id = aws_vpc.main.id

  
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_egress.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_egress" {
  count     = length(aws_subnet.private_egress[*].id)
  subnet_id = aws_subnet.private_egress[count.index].id

  route_table_id = aws_route_table.private_egress.id
}

