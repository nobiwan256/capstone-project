# Create a VPC to launch our instances into
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"  
  enable_dns_hostnames = true 
  enable_dns_support = true
  
  tags = {
    Name = "deham9-vpc"
  }       
}

# Public Subnet 1
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "deham9-public-1"
  }
}

# Private Subnet 1
resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.dev_vpc.id 
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "deham9-private-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "deham9-public-2"
  }
}

# Private Subnet 2
resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.dev_vpc.id 
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "deham9-private-2"
  }
}

# Create an Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "deham9-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "deham9-public-rt"
  }
}

# Private Route Table (No NAT Gateway - traffic remains internal)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "deham9-private-rt"
  }
}

# Associate Public Subnet 1 with Public Route Table
resource "aws_route_table_association" "public_subnet1_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public-1.id
}

# Associate Public Subnet 2 with Public Route Table
resource "aws_route_table_association" "public_subnet2_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public-2.id
}

# Associate Private Subnet 1 with Private Route Table
resource "aws_route_table_association" "private_subnet1_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private-1.id
}

# Associate Private Subnet 2 with Private Route Table
resource "aws_route_table_association" "private_subnet2_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private-2.id
}

# Terraform Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
