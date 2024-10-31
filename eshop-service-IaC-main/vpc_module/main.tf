#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * NAT Gateway
#  * Route Table
#  * EIP
#

data "aws_availability_zones" "available" {}

resource "aws_vpc" "service" {
  cidr_block = "192.168.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "eshop-service-terraform-vpc",
  }
}


resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.service.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "192.168.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = tomap({
    Name = "eshop-service-terraform-public-subnet${count.index + 1}",
    "kubernetes.io/cluster/eshop-service-${var.cluster_name}" = "shared",
  })
}


resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.service.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "192.168.1${count.index}.0/24"
  map_public_ip_on_launch = false

  tags = tomap({
    Name = "eshop-service-terraform-private-subnet${count.index + 1}",
    "kubernetes.io/cluster/eshop-service-${var.cluster_name}" = "shared",
  })
}


resource "aws_internet_gateway" "service" {
  vpc_id = aws_vpc.service.id

  tags = {
    Name = "eshop-service-terraform-igw"
  }
}

resource "aws_nat_gateway" "service" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.service]

  tags = {
    Name = "eshop-service-terraform-ngw"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.service.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.service.id
  }

  tags = {
    Name = "eshop-service-terraform-public-route"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.service.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.service.id
  }

  tags = {
    Name = "eshop-service-terraform-private-route",
  }
}


resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat" {
  #vpc        = true
  depends_on = [aws_internet_gateway.service]

  tags = {
    Name = "eshop-service-terraform-NAT"
  }
}


resource "aws_eip" "eip1" {
  #vpc  = true
  tags = {
    Name = "eshop-service-terraform-EIP1"
  }
}


resource "aws_eip" "eip2" {
  #vpc  = true
  tags = {
    Name = "eshop-service-terraform EIP2"
  }
}

