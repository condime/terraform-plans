resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  # Need one route table per AZ, as each uses a separate NAT
  count = local.subnet_count

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(var.ipv4_nat_ids, count.index % local.nat_count)
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = var.ipv6_gateway_id
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "private"
  }
}

# Attach each subnet to the route table
resource "aws_route_table_association" "private" {
  count     = local.subnet_count
  subnet_id = element(aws_subnet.private.*.id, count.index)

  route_table_id = element(aws_route_table.private.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }
}
