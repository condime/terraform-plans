# Cloudwatch Logs -> Kinesis Firehose -> Honeycomb

locals {
  honeycomb_dataset = "nfraclub"
  cloudwatch_log_groups = [
    aws_cloudwatch_log_group.ecs-mastodon.name,
    aws_cloudwatch_log_group.elasticache-mastodon.name,
  ]
}

# Step 1: Setup a cloudwatch log subscription for the provided log groups
resource "aws_cloudwatch_log_subscription_filter" "honeycomb" {
  count = length(local.cloudwatch_log_groups)

  name           = "${local.cloudwatch_log_groups[count.index]}-logs-to-honeycomb"
  role_arn       = aws_iam_role.honeycomb-logs.arn
  log_group_name = local.cloudwatch_log_groups[count.index]

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.honeycomb.arn
}

# Step 2: Forward to honeycomb's API via Firehose Streams
resource "aws_kinesis_firehose_delivery_stream" "honeycomb" {
  name        = "honeycomb-logs"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = "https://api.honeycomb.io/1/kinesis_events/${local.honeycomb_dataset}"
    name               = "honeycomb"
    access_key         = data.consul_keys.honeycomb.var.honeycomb_api_key
    role_arn           = aws_iam_role.honeycomb-firehose.arn
    s3_backup_mode     = "FailedDataOnly"
    buffering_size     = 15
    buffering_interval = 60

    request_configuration {
      content_encoding = "GZIP"
    }

    s3_configuration {
      role_arn   = aws_iam_role.honeycomb-firehose.arn
      bucket_arn = aws_s3_bucket.honeycomb-s3.arn

      # https://docs.aws.amazon.com/firehose/latest/dev/create-configure.html
      # https://github.com/honeycombio/terraform-aws-integrations/blob/main/modules/kinesis-firehose-honeycomb/variables.tf
      buffer_size        = 10
      buffer_interval    = 400
      compression_format = "GZIP"
    }


  }
}
