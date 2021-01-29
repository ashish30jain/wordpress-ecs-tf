
module "vpc" {
  source                    = "git::https://github.com/tmknom/terraform-aws-vpc.git?ref=tags/2.0.1"
  cidr_block                = local.cidr_block
  name                      = "ecs-fargate-vpc"
  public_subnet_cidr_blocks = [cidrsubnet(local.public_cidr_block, 5, 0), cidrsubnet(local.public_cidr_block, 5 , 4 ),cidrsubnet(local.public_cidr_block, 5 , 8 )]
  public_availability_zones = data.aws_availability_zones.available.names
  private_subnet_cidr_blocks = [cidrsubnet(local.private_cidr_block, 5, 0), cidrsubnet(local.private_cidr_block, 5 , 4 ),cidrsubnet(local.private_cidr_block, 5 , 8 )]
  private_availability_zones = data.aws_availability_zones.available.names

  instance_tenancy        = "default"
  enable_dns_support      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false

  enabled_nat_gateway        = true
  enabled_single_nat_gateway = false  
}

locals {
  cidr_block = "10.255.0.0/19"
  private_cidr_block = "10.255.0.0/21"
  public_cidr_block = "10.255.8.0/21"
}
