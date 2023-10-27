resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "default" {
  count = local.nat_count

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}
