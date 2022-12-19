resource "aws_ecs_service" "this" {
  name    = var.name
  cluster = var.ecs_cluster_id

  platform_version       = "LATEST"
  enable_execute_command = true

  # AWS Managed, when on Fargate this is not configurable
  # service role: Used to register into load balancers
  #iam_role = "aws-service-role"

  task_definition = aws_ecs_task_definition.this.arn
  propagate_tags  = "SERVICE"

  health_check_grace_period_seconds = length(var.load_balancers) == 0 ? null : 60

  dynamic "load_balancer" {
    for_each = var.load_balancers

    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries

    content {
      registry_arn   = service_registries.value["registry_arn"]
      container_name = service_registries.value["container_name"]
      container_port = lookup(service_registries.value, "container_port", null)
    }
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  desired_count = 0
  lifecycle {
    ignore_changes = [desired_count]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }
}
