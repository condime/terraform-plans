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

  image_id = data.aws_ami.al2023.id
  instance_type = "t4g.nano"

  user_data = var.user_data

  tags = {
    Name = var.name
  }
}

# https://aws.amazon.com/blogs/aws/amazon-linux-2023-a-cloud-optimized-linux-distribution-with-long-term-support/
data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^al2023-ami-2023.0."

  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.*"]
  }
  
  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
