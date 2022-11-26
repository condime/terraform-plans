resource "aws_cloudwatch_log_group" "ecs-mastodon" {
  name = "/ecs/mastodon"

  retention_in_days = 30
  #kms_key_id = ...
}
