resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  # Need one route table per AZ, as each may use a separate NAT
  count = local.subnet_count

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route" "default_ipv6" {
  count                       = local.subnet_count
  route_table_id              = element(aws_route_table.private.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = var.ipv6_gateway_id
}

resource "aws_route" "default_ipv4" {
  count                  = local.nat_instance_count
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.nat_instance_eni_ids, count.index)
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
