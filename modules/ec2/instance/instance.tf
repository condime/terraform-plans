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

  lifecycle {
    ignore_changes = [user_data]
  }

  # Other options: explicit defaults
  hibernation = false

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  enclave_options {
    enabled = false
  }

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
}

resource "aws_launch_template" "this" {
  name = var.name

  image_id      = data.aws_ami.al2023.id
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
  name_regex  = "^al2023-ami-2023.3."

  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  filter {
    name   = "hypervisor"
    values = ["xen"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
