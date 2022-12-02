output "instance_id" {
  value = data.aws_instance.this.id
}

output "eni_id" {
  value = data.aws_instance.this.network_interface_id
}
