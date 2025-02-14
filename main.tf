# ==============
# 🚀 NETWORK SETUP
# ==============

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "MyWordPressVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSubnet2"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MyPrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "MyPrivateSubnet2"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyPublicRouteTable"
  }
}

# Create Public Route for Internet Access
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ==============
# 🔒 SECURITY GROUPS
# ==============

# ALB Security Group (Allows HTTP)
resource "aws_security_group" "alb_sg" {
  name        = "ALBSecurityGroup"
  description = "Security Group for ALB (Allows HTTP)"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALBSecurityGroup"
  }
}

# EC2 Security Group (Allows HTTP from ALB, SSH from anywhere)
resource "aws_security_group" "ec2_sg" {
  name        = "EC2SecurityGroup"
  description = "Security Group for EC2 (Allows HTTP from ALB, SSH from anywhere)"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb_sg.id] # HTTP from ALB
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2SecurityGroup"
  }
}

# RDS Security Group (Allows MySQL from EC2)
resource "aws_security_group" "rds_sg" {
  name        = "RDSSecurityGroup"
  description = "Security Group for RDS (Allows MySQL from EC2)"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.ec2_sg.id] # Allow MySQL from EC2
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSSecurityGroup"
  }
}

# ==============
# 📤 OUTPUTS
# ==============

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "public_subnet_1_id" {
  description = "The first public subnet ID"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "The second public subnet ID"
  value       = aws_subnet.public_subnet_2.id
}

output "private_subnet_1_id" {
  description = "The first private subnet ID"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "The second private subnet ID"
  value       = aws_subnet.private_subnet_2.id
}

output "alb_security_group_id" {
  description = "The security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "The security group ID for EC2"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "The security group ID for RDS"
  value       = aws_security_group.rds_sg.id
}
