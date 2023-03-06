output "instance_id" {
  value = aws_instance.this.id
}

output "eni_id" {
  value = aws_network_interface.this.id
}
