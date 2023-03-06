resource "aws_instance" "this" {
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }

  iam_instance_profile = var.instance_profile_name

  tags = {
    "Name" = var.name
  }
}

resource "aws_launch_template" "this" {
  name = var.name

  image_id = "ami-006c19cfa0e8f4672"
  instance_type = "t4g.nano"

  user_data = var.user_data

  tags = {
    Name = var.name
  }
}

data "aws_ami" "al2" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^amzn2-ami-kernel-"

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
