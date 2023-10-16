resource "aws_ecs_task_definition" "this" {
  family = var.name

  cpu    = var.task_cpu
  memory = var.task_memory

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode(var.container_definitions)

  depends_on = [
    var.execution_role_arn,
    var.task_role_arn,
  ]

  tags = {}
}
