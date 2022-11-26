output "vpc_id" {
  value = aws_vpc.default.id
}

output "vpc_cidr_v4" {
  value = aws_vpc.default.cidr_block
}

output "vpc_cidr_v6" {
  value = aws_vpc.default.ipv6_cidr_block
}

output "gateway_id" {
  value = aws_internet_gateway.default.id
}

output "egress_only_gateway_id" {
  value = aws_egress_only_internet_gateway.default.id
}
