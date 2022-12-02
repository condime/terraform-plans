resource "aws_subnet" "private" {
  count = local.subnet_count

  vpc_id            = var.vpc_id
  availability_zone = element(var.azs, count.index)

  cidr_block      = cidrsubnet(var.cidr_v4, 4, 8 + count.index)
  ipv6_cidr_block = cidrsubnet(var.cidr_v6, 8, 1 + count.index)

  tags = {
    Name = "private"
  }
}
