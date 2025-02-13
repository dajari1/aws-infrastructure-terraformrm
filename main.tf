resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-infra-terraform-VPC"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-infra-terraform-IGW"
  }
}
# Public Subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-infra-terraform-Public-Subnet"
  }
}
# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "aws-infra-terraform-Private-Subnet"
  }
}
# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-infra-terraform-Public-RT"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-infra-terraform-Private-RT"
  }
}
# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# EC2 Instance in the Public Subnet
resource "aws_instance" "web_public" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  user_data                   = file("nginx.sh")
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  key_name                    = "denn"
  tags = {
    Name = "aws-infra-terraform-Public-ec2"
  }
}

# EC2 Instance in the Private Subnet
resource "aws_instance" "web_private" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  key_name                    = "denn"
  tags = {
    Name = "aws-infra-terraform-Private-ec2"
  }
}

