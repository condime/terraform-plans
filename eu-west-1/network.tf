data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "../modules/vpc"
  name   = "nfra.club"
}

module "public_subnets" {
  source = "../modules/subnets/public"
  azs    = data.aws_availability_zones.azs.names

  vpc_id  = module.vpc.vpc_id
  cidr_v4 = module.vpc.vpc_cidr_v4
  cidr_v6 = module.vpc.vpc_cidr_v6

  ipv4_gateway_id = module.vpc.gateway_id
  ipv6_gateway_id = module.vpc.gateway_id

  # Cheap mode: Not advisable, but subnets without a NAT GW
  # can still access the internet by routing to a sibling subnet.
  # If the AZ with the NAT is unavailable, all other subnets
  nat_count = 0

  # Cheap mode: This is the minimum needed for ALBs to be accepted
  subnet_count = 2
}

module "private_subnets" {
  source = "../modules/subnets/private"
  azs    = data.aws_availability_zones.azs.names

  vpc_id  = module.vpc.vpc_id
  cidr_v4 = module.vpc.vpc_cidr_v4
  cidr_v6 = module.vpc.vpc_cidr_v6

  nat_instance_eni_ids = module.nat_instance.*.eni_id
  ipv6_gateway_id      = module.vpc.egress_only_gateway_id

  # Cheap mode: Literally the fewest possible
  subnet_count = 1
}


# Cheap mode: NAT Instances are EC2 instances with some IP checks disabled
# Linux iptables performs POSTROUTING S-NAT if your bill is dominated by NAT GW hours
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
module "nat_instance" {
  source = "../modules/ec2/instance"
  name   = "nat"
  count  = 1

  # Required for NAT to perform it's lies
  source_dest_check = false

  subnet_id            = element(module.public_subnets.subnet_ids, count.index)
  security_group_ids   = [aws_security_group.default.id]
  instance_profile_arn = aws_iam_instance_profile.nat.arn

  user_data = filebase64("${path.module}/user_data/nat.tpl")
}
