variable "vpc_id" {}

variable "azs" {
  type = list(string)
}

variable "cidr_v4" {}
variable "cidr_v6" {}

variable "ipv4_nat_ids" {
  type    = list(string)
  default = []
}

variable "nat_instance_eni_ids" {
  type    = list(string)
  default = []
}

variable "ipv6_gateway_id" {}

variable "subnet_count" {
  default = 0
}

locals {
  nat_count          = length(var.ipv4_nat_ids)
  subnet_count       = min(length(var.azs), var.subnet_count)
  nat_instance_count = min(length(var.nat_instance_eni_ids), local.subnet_count)
}
