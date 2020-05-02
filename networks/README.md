## [networks](https://github.com/amitzworld/Terraform/tree/master/networks)

### This will create networkings resources like- vpc, subnets etc. on AWS Cloud
- **VPC** with cidr_block 192.168.0.0/16 
- **Subnets** 2 Public and 1 Private Subnet.
- **Internet Gateway** associate it to respective route tables for public subnet.
- **NAT Gateway** associate it to respective route tables for private subnet.
