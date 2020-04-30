##Creating following resources
##VPC, Public and Private Subnet, Route tables, IG, NG 
##Author: AmitZworld, https://github.com/amitzworld

provider "aws"  {
  region = "ap-south-1"
  shared_credentials_file = "~/.aws/credentials"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "Mumbai VPC"
  }
}
resource "aws_subnet" "private_subnet" {
  cidr_block = "192.168.0.0/20"
  vpc_id = "${aws_vpc.my_vpc.id}"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Private Subnet"
  }
}
resource "aws_subnet" "public_subnet" {
  cidr_block = "192.168.16.0/20"
  vpc_id = "${aws_vpc.my_vpc.id}"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1"
  }
}
resource "aws_subnet" "public_subnet1" {
  cidr_block = "192.168.32.0/20"
  vpc_id = "${aws_vpc.my_vpc.id}"
  availability_zone = "ap-south-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 2"
  }
}
resource "aws_route_table" "route_table_public" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  route {
    gateway_id = "${aws_internet_gateway.internate_gateway.id}"
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "Public Route Table"
  }
}
resource "aws_route_table" "route_table_private" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  route {
    gateway_id = "${aws_nat_gateway.nat_gateway.id}"
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "Private Route Table"
  }
}
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = "${aws_route_table.route_table_public.id}"
  subnet_id = "${aws_subnet.public_subnet.id}"
}
resource "aws_route_table_association" "public1_subnet_association" {
  route_table_id = "${aws_route_table.route_table_public.id}"
  subnet_id = "${aws_subnet.public_subnet1.id}"
}
resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = "${aws_route_table.route_table_private.id}"
  subnet_id = "${aws_subnet.private_subnet.id}"
}
resource "aws_internet_gateway" "internate_gateway" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  tags = {
    Name = "Internet Gateway"
  }
}
resource "aws_eip" "elastic_ip" {
  vpc = true
  tags = {
    Name = "NAT-Gateway-EIP"
  }
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.elastic_ip.id}"
  subnet_id = "${aws_subnet.public_subnet.id}"
  tags = {
    Name = "NAT-Gateway"	
  }
}


