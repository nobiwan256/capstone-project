resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "deham9-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = { Name = "deham9-public-1" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = { Name = "deham9-private-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = { Name = "deham9-public-2" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = { Name = "deham9-private-2" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = { Name = "deham9-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "deham9-public-rt" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = { Name = "deham9-private-rt" }
}

resource "aws_route_table_association" "public_1_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_route_table_association" "public_2_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_2.id
}

resource "aws_route_table_association" "private_1_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_route_table_association" "private_2_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_2.id
}
