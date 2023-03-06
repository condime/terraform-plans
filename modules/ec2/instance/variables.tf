variable "name" {}

variable "subnet_id" {}
variable "instance_profile_name" {}

variable "security_group_ids" {
  type = list(string)
}

variable "source_dest_check" {
  type    = bool
  default = true
}

variable "user_data" {}
