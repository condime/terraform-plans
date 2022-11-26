resource "aws_subnet" "public" {
  count = local.subnet_count

  vpc_id            = var.vpc_id
  availability_zone = element(var.azs, count.index)

  cidr_block      = cidrsubnet(var.cidr_v4, 4, count.index)
  ipv6_cidr_block = cidrsubnet(var.cidr_v6, 8, count.index * 16)

  tags = {
    Name = "public"
  }
}
