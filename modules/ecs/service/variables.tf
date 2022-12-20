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
#
# CPU value | Memory values
# 256       | 512, 1024, 2048
# 512       | 1024, 2048, 4096, 8192
# 1024      | 2048, 3072, 4096, 5120, 6144, 7168, 8192
# 2048      | 4096, 5120, 5144, 7168, 8192, ... in 1G increments until 16384
# 4096      | 8192, ... in 1G increments until 32768
# 8192*     | 16384, ... in 4G increments until 63436
# 16384*    | 32768, ... in 8G increments until 126872
# *Requires fargate platform 1.4+
variable "task_cpu" {
  default = 256
}
variable "task_memory" {
  default = 512
}

variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "container_definitions" {}
