resource "aws_elasticache_subnet_group" "mastodon" {
  name       = "mastodon"
  subnet_ids = module.private_subnets.subnet_ids
}

# Cheap mode: Only provision one redis instance
#
# Bias behaviour for sidekiq's requirements.
# There are scheduled tasks to help with cache eviction, however
# at the first sign of memory pressure, consider separating queues from caches.
resource "aws_elasticache_replication_group" "mastodon" {
  description = "single-host redis for mastodon"

  replication_group_id = "mastodon"
  parameter_group_name = aws_elasticache_parameter_group.sidekiq-redis6.name

  engine         = "redis"
  engine_version = "6.2"
  node_type      = "cache.t4g.micro"

  num_cache_clusters      = 1
  replicas_per_node_group = 0

  # Features
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # https://github.com/mastodon/mastodon/issues/19824
  auto_minor_version_upgrade = "true"

  automatic_failover_enabled = false
  multi_az_enabled           = false
  data_tiering_enabled       = false
  snapshot_retention_limit   = 0

  subnet_group_name = aws_elasticache_subnet_group.mastodon.name
  security_group_ids = [
    aws_security_group.default.id,
  ]

  log_delivery_configuration {
    destination_type = "cloudwatch-logs"
    destination      = aws_cloudwatch_log_group.elasticache-mastodon.name
    log_format       = "text"       # or "json"
    log_type         = "engine-log" # or "slow-log"???
  }
}

resource "aws_elasticache_parameter_group" "sidekiq-redis6" {
  name   = "sidekiq-redis6"
  family = "redis6.x"

  description = "Non-clustered parameter group for sidekiq"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

resource "aws_elasticache_parameter_group" "cache-redis6" {
  name   = "cache-redis6"
  family = "redis6.x"

  description = "Non-clustered parameter group for rails cache"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

locals {
  #mastodon_redis_url = "redis://${aws_elasticache_replication_group.mastodon.primary_endpoint_address}:${aws_elasticache_replication_group.mastodon.port}"
  mastodon_redis_url = "redis://${aws_elasticache_replication_group.mastodon.primary_endpoint_address}:6379"
}
