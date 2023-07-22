resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.eu-west-1.s3"
  vpc_id       = module.vpc.vpc_id

  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.private_subnets.route_table_ids
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoints)

  service_name      = each.key
  vpc_endpoint_type = "Interface"
  vpc_id            = module.vpc.vpc_id

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.default.id]
  subnet_ids          = module.private_subnets.subnet_ids
}

locals {
  interface_endpoints = [
    # Used to connect to EC2 instances
    #"com.amazonaws.eu-west-1.ec2messages",
    #"com.amazonaws.eu-west-1.ssm",
    #"com.amazonaws.eu-west-1.ssmmessages",

    # Used to start Fargate Containers
    #"com.amazonaws.eu-west-1.ecr.api",
    #"com.amazonaws.eu-west-1.logs",
  ]
}
