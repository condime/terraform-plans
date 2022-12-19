module "ecs" {
  source = "../modules/ecs"

  cluster_name = "default"
}

module "mastodon-web" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-web"

  service_registries = [
    {
      registry_arn   = aws_service_discovery_service.mastodon-web.arn
      container_name = "web"
    }
  ]

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  task_cpu    = "512"
  task_memory = "2048"

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.web_container_definitions
}

module "mastodon-scheduler" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-scheduler"

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.sidekiq_scheduler_container_definitions
}

module "mastodon-ingress" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-ingress"

  task_cpu    = "512"
  task_memory = "2048"

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.sidekiq_ingress_container_definitions
}

module "mastodon-push" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-push"

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.sidekiq_push_container_definitions
}

module "mastodon-pull" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-pull"

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.sidekiq_pull_container_definitions
}

module "mastodon-sidekiq" {
  source         = "../modules/ecs/service"
  ecs_cluster_id = module.ecs.cluster_id

  name = "mastodon-sidekiq"

  subnet_ids         = module.private_subnets.subnet_ids
  security_group_ids = [aws_security_group.default.id]

  execution_role_arn = aws_iam_role.mastodon-execution-role.arn
  task_role_arn      = aws_iam_role.mastodon-task-role.arn

  container_definitions = local.sidekiq_container_definitions
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
    TRUSTED_PROXY_IP         = data.consul_keys.mastodon.var.trusted_proxy_ip
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
    S3_PERMISSION           = "private"

    SMTP_SERVER       = "citadel.condi.me"
    SMTP_PORT         = "26"
    SMTP_LOGIN        = "nfra"
    SMTP_PASSWORD     = data.consul_keys.mastodon.var.smtp_password
    SMTP_FROM_ADDRESS = "notifications@nfra.club"

    VAPID_PRIVATE_KEY = data.consul_keys.mastodon.var.vapid_private_key
    VAPID_PUBLIC_KEY  = data.consul_keys.mastodon.var.vapid_public_key
  }
}
