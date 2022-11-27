resource "aws_ecs_cluster" "default" {
  name = "default"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.default.name

  capacity_providers = [
    "FARGATE_SPOT",
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }
}

resource "aws_ecs_service" "mastodon" {
  name    = "mastodon"
  cluster = aws_ecs_cluster.default.id

  platform_version       = "LATEST"
  enable_execute_command = true

  # AWS Managed, when on Fargate this is not configurable
  # service role: Used to register into load balancers
  #iam_role = "aws-service-role"

  # task role: Used by the containers, referenced in task definition
  depends_on      = [aws_iam_role.mastodon-task-role]
  task_definition = aws_ecs_task_definition.mastodon.arn

  propagate_tags                    = "NONE"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.mastodon-web.arn
    container_name   = "web"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mastodon-streaming.arn
    container_name   = "streaming"
    container_port   = 4000
  }

  network_configuration {
    subnets          = module.private_subnets.subnet_ids
    security_groups  = [aws_security_group.default.id]
    assign_public_ip = false
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  desired_count = 1

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {}
}

resource "aws_ecs_task_definition" "mastodon" {
  family = "mastodon"

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size
  cpu    = "512"
  memory = "1024"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = jsonencode([
    {
      command     = ["bundle", "exec", "puma", "-C", "config/puma.rb"]
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
      mountPoints = []
      name        = "web"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      volumesFrom = []
    },

    {
      command     = ["node", "./streaming"]
      cpu         = 0
      environment = [for k, v in local.environment : { "name" : k, "value" : v }]
      essential   = true
      image       = "${aws_ecr_repository.mastodon.repository_url}${local.container_image_tag}"
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
      mountPoints = []
      name        = "streaming"
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        }
      ]
      volumesFrom = []
    },

    {
      command     = ["bundle", "exec", "sidekiq"]
      cpu         = 0
      environment = [for k, v in local.environment : { "name" : k, "value" : v }]
      essential   = true
      image       = "${aws_ecr_repository.mastodon.repository_url}${local.container_image_tag}"

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
      name         = "sidekiq"
      portMappings = []
      volumesFrom  = []
    }
  ])

  depends_on = [aws_iam_role.mastodon-task-role]
}

locals {
  container_image_tag = "@sha256:4dc1efcfe81f8fd46310e3bcdcde610e2586c36da968ad18642634d1173e3371"

  environment = {
    # Mastodon (via kt-paperclip) does not know how to use task role credentials
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.mastodon-useruploads.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.mastodon-useruploads.secret

    DATABASE_URL = data.consul_keys.mastodon.var.database_url
    REDIS_URL    = local.mastodon_redis_url

    BIND                     = "0.0.0.0"
    LOCAL_DOMAIN             = "nfra.club"
    RAILS_ENV                = "production"
    CDN_HOST                 = "https://static.nfra.club"
    STREAMING_API_BASE_URL   = "wss://streaming.nfra.club"
    RAILS_SERVE_STATIC_FILES = "true"
    PAPERCLIP_ROOT_PATH      = "/var/lib/mastodon/userassets"

    OTP_SECRET      = data.consul_keys.mastodon.var.otp_secret
    SECRET_KEY_BASE = data.consul_keys.mastodon.var.secret_key_base

    S3_BUCKET               = aws_s3_bucket.mastodon-useruploads.id
    S3_ENABLED              = "true"
    S3_REGION               = "eu-west-1"
    S3_ALIAS_HOST           = "useruploads.nfra.club"
    S3_FORCE_SINGLE_REQUEST = "true"

    SMTP_SERVER       = "citadel.condi.me"
    SMTP_PORT         = "26"
    SMTP_LOGIN        = "nfra"
    SMTP_PASSWORD     = data.consul_keys.mastodon.var.smtp_password
    SMTP_FROM_ADDRESS = "notifications@nfra.club"

    VAPID_PRIVATE_KEY = data.consul_keys.mastodon.var.vapid_private_key
    VAPID_PUBLIC_KEY  = data.consul_keys.mastodon.var.vapid_public_key
  }
}
