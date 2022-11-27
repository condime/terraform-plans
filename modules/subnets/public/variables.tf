variable "vpc_id" {}

variable "azs" {
  type = list(any)
}

variable "cidr_v4" {}
variable "cidr_v6" {}

variable "ipv4_gateway_id" {}
variable "ipv6_gateway_id" {}

variable "nat_count" {
  default = 0
}

variable "subnet_count" {
  default = 0
}

locals {
  nat_count    = min(var.nat_count, local.subnet_count)
  subnet_count = min(length(var.azs), var.subnet_count)
}
