##Creating following resources
##VPC, Public and Private Subnet, Route tables, Security Group, EC2, ALB
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
}

resource "aws_security_group" "my_sg" {
  name = "webserver_sg"
  vpc_id = "${aws_vpc.my_vpc.id}"
}
resource "aws_security_group_rule" "allow_port" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.my_sg.id}"
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_port1" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.my_sg.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group" "my_alb_sg" {
  name = "webserver_alb_sg"
  vpc_id = "${aws_vpc.my_vpc.id}"
}
resource "aws_security_group_rule" "allow_port2" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.my_alb_sg.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_out" {
  from_port = 0
  protocol = "tcp"
  security_group_id = "${aws_security_group.my_alb_sg.id}"
  to_port = 65535
  type = "egress"
  source_security_group_id = "${aws_security_group.my_sg.id}"
}
resource "aws_security_group_rule" "allow_out1" {
  from_port = 0
  protocol = "tcp"
  security_group_id = "${aws_security_group.my_sg.id}"
  to_port = 65535
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_instance" "my_instances" {
  ami = "ami-0217a85e28e625474"
  instance_type = "t2.micro"
  key_name = "mumbai_servers"
 // security_groups = [aws_security_group.my_sg.name]
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  user_data = "${file("install_httpd.sh")}"
  subnet_id = "${aws_subnet.public_subnet.id}"
tags = {
  Name =  "Webserver"
}
}
resource "aws_alb_target_group" "mytarget" {
  name = "test-targets"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.my_vpc.id}"

}
resource "aws_alb_target_group_attachment" "my_target_group" {
  target_group_arn = "${aws_alb_target_group.mytarget.arn}"
  target_id = "${aws_instance.my_instances.id}"
  port = 80
}
resource "aws_lb" "mylb" {
  name = "my-first-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.my_alb_sg.id]
//  subnets            = ["subnet-4a82b722", "subnet-e368f2af"]
// subnets = ["${aws_subnet.public.*.id}"]
//  subnets            = ["${aws_subnet.public.*.id}"]
  subnets = ["${aws_subnet.public_subnet.id}", "${aws_subnet.public_subnet1.id}"]
  tags = {
    Env = "Test"
  }
}
resource "aws_alb_listener" "my_listener" {
  load_balancer_arn = "${aws_lb.mylb.arn}"
  port = 80
  default_action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.mytarget.arn}"
  }
}
output "EC2_Public_IP" {
  value = "${aws_instance.my_instances.public_ip}"
}
output "ALB_Cname" {
  value = "${aws_lb.mylb.dns_name}"
}
