resource "aws_eip" "this" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "this" {
  allocation_id = aws_eip.this.id
  instance_id   = data.aws_instance.this.id

  allow_reassociation = true
}
