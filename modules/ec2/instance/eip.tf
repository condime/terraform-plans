resource "aws_eip" "this" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "this" {
  allocation_id        = aws_eip.this.id
  network_interface_id = aws_network_interface.this.id
  allow_reassociation  = true
}

resource "aws_network_interface" "this" {
  subnet_id         = var.subnet_id
  source_dest_check = var.source_dest_check
}
