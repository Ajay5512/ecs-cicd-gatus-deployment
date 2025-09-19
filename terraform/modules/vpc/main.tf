locals {
  public_cidrs  = ["10.0.0.0/26", "10.0.0.64/26"]
  private_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]
  azs           = ["us-east-1a", "us-east-1b"]
}

resource "aws_vpc" "network" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "ecs-vpc", Project = "main", Tier = "main" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.network.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name    = "public-${count.index + 1}"
    Tier    = "public"
    Project = "main"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.network.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name    = "private-${count.index + 1}"
    Tier    = "private"
    Project = "main"
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.network.id
  tags   = { Name = "public-nacl" }
}

resource "aws_network_acl_rule" "public" {
  for_each       = { for i, r in var.publicnacl_config : i => r }
  network_acl_id = aws_network_acl.public.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.network.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.network.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "nat-eip" }
}


resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
}
