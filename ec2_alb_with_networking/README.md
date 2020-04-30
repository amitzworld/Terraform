## [ec2_alb_with_networking](https://github.com/amitzworld/Terraform/tree/master/ec2_alb_with_networking)

### This will create multiple resources on AWS
 - Prerequisite
	- Make sure you have passed aws keys in ~/.aws/credentials file.
	- Make sure you've referred existing key_name in resource aws_instance block.
 - Following resources will be created in Mumbai region.
	- First, It will create all networking resources like- **VPC, Subnets, Route Table, Internet Gateway, NAT Gateway, Security Group**.
	- Allow ingress traffic for port 22 and 80.
	- **An EC2** using Amazon Linux AMI with userdata to install http server.
	- **An ALB** and dependent resource like- target group and associates the EC2 on port 80.
