resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.project_id}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = {
    Name        = "${var.project_id}-privatesubnet${count.index}-${var.availability_zones[count.index % length(var.availability_zones)]}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project_id}-publicsubnet${count.index}-${var.availability_zones[count.index % length(var.availability_zones)]}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name        = "${var.project_id}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "publicrtb" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.project_id}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "a" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.publicrtb.id
}

resource "aws_eip" "nat_eip" {
  count = length(var.public_subnets)
  tags = {
    Name        = "${var.project_id}-nat-eip-${count.index}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name        = "${var.project_id}-natgw-${count.index}"
    Environment = var.environment
  }
}

resource "aws_route_table" "privatertb" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index % length(aws_nat_gateway.nat_gw)].id
  }

  tags = {
    Name        = "${var.project_id}-private-rt-${count.index}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.privatertb[count.index].id
}
