data "aws_availability_zones" "available" {}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.name}-vpc"
  }
}
resource "aws_subnet" "subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  tags = {
    name = "${var.name}-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    name = "${var.name}-igw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    name = "${var.name}-rt"
  }
}
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}