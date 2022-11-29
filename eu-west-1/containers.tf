locals {
  web_container_definitions = [
    merge(local.common_container_definitions, {
      name    = "web"
      command = ["bundle", "exec", "puma", "-C", "config/puma.rb"]

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }),

    merge(local.common_container_definitions, {
      name    = "streaming"
      command = ["node", "./streaming"]
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        }
      ]
    }),
  ]

  sidekiq_container_definitions = [
    merge(local.common_container_definitions, {
      # Everything except for "scheduler"
      name = "sidekiq"
      command = [
        "bundle", "exec", "sidekiq",
        "-q", "default",
        "-q", "ingress",
        "-q", "mailers",
        "-q", "pull",
        "-q", "push",
      ]
    }),
  ]

  # Only ever run one of these
  sidekiq_scheduler_container_definitions = [
    merge(local.common_container_definitions, {
      name = "sidekiq-scheduler"
      command = [
        "bundle", "exec", "sidekiq", "-q", "scheduler",
      ]
    }),
  ]

  common_container_definitions = {
    cpu         = 0
    environment = [for k, v in local.environment : { "name" : k, "value" : v }]
    essential   = true
    image       = "${aws_ecr_repository.mastodon.repository_url}${local.container_image_tag}"

    linuxParameters = {
      initProcessEnabled = true
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-create-group"  = "true"
        "awslogs-group"         = "/ecs/mastodon"
        "awslogs-region"        = "eu-west-1"
        "awslogs-stream-prefix" = "ecs"
      }
      secretOptions = []
    }

    mountPoints  = []
    portMappings = []
    volumesFrom  = []
  }
}

