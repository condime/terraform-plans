resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_egress_only_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}
