resource "aws_service_discovery_private_dns_namespace" "mastodon" {
  name        = "mastodon.local"
  description = "Internal DNS Discovery for Mastodon Services"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "mastodon-web" {
  name = "web"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.mastodon.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # ECS managed healthchecks
  health_check_custom_config {
    failure_threshold = 1
  }
}
