resource "aws_security_group" "default" {
  name        = "default"
  description = "default VPC security group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "default"
  }
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.default.id

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  ipv6_cidr_blocks = [
    "::/0",
  ]
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.default.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  ipv6_cidr_blocks = [
    "::/0",
  ]
}
