data "aws_instance" "this" {
  depends_on = [aws_autoscaling_group.this]

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.name]
  }
}

resource "aws_autoscaling_group" "this" {
  name     = var.name
  max_size = 1
  min_size = 1

  desired_capacity = 1
  lifecycle {
    ignore_changes = [desired_capacity]
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.subnet_id]

  tag {
    key   = "Name"
    value = var.name

    propagate_at_launch = true
  }
}

resource "aws_launch_template" "this" {
  name = var.name

  image_id = "ami-006c19cfa0e8f4672"
  iam_instance_profile {
    arn = var.instance_profile_arn
  }
  instance_type = "t4g.nano"

  instance_market_options {
    market_type = "spot"
  }

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
