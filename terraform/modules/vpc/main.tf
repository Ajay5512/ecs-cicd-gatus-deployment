resource "aws_vpc" "network" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "ecs-vpc", Project = "main", Tier = "main" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.network.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-1", Tier = "public" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.network.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-2", Tier = "public" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.network.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "eu-west-2a"
  tags              = { Name = "private-1", Tier = "private" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.network.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "eu-west-2b"
  tags              = { Name = "private-2", Tier = "private" }
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

resource "aws_network_acl_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
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
  for_each = {
    public_1 = aws_subnet.public_1.id
    public_2 = aws_subnet.public_2.id
  }
  subnet_id      = each.value
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
  for_each = {
    private_1 = aws_subnet.private_1.id
    private_2 = aws_subnet.private_2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "nat-eip" }
}


resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.igw]
}
