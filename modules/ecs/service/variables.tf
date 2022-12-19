variable "ecs_cluster_id" {}
variable "name" {}

variable "load_balancers" {
  type    = list(any)
  default = []
}

variable "service_registries" {
  type    = list(any)
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size
variable "task_cpu" {
  default = 256
}
variable "task_memory" {
  default = 512
}

variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "container_definitions" {}
