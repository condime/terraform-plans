resource "aws_cloudfront_distribution" "mastodon-useruploads" {
  aliases = [
    "useruploads.nfra.club",
  ]

  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name = "nfraclubuserassets.s3.eu-west-1.amazonaws.com"
    origin_id   = "nfraclubuserassets.s3.eu-west-1.amazonaws.com"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
    target_origin_id = "nfraclubuserassets.s3.eu-west-1.amazonaws.com"
 }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:055237546114:certificate/c4a4539a-a2c3-4c63-b133-ab29ea03da1e"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  wait_for_deployment = false
}

locals {
  application_paths = [
    "/",
    "/@*",
    "/api/*",
    "/actor/*",
    "/admin/*",
    "/auth/*",
    "/authorize_interaction*",
    "/disputes/*",
    "/filters*",
    "/inbox*",
    "/invites*",
    "/oauth/*",
    "/pghero/*",
    "/relationships*",
    "/sidekiq/*",
    "/settings/*",
    "/statuses_cleanup*",
    "/share*",
    "/users/*",
  ]
}

resource "aws_cloudfront_distribution" "mastodon-assets" {
  aliases = [
    "nfra.club",
  ]

  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    connection_attempts = 3
    connection_timeout  = 1

    domain_name = aws_s3_bucket.mastodon-static.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.mastodon-static.bucket_regional_domain_name

    s3_origin_config {
      # XXX: Public
      # Consider using an access identity?
      origin_access_identity = ""
    }
  }

  origin {
    domain_name = aws_lb.mastodon.dns_name
    origin_id   = aws_lb.mastodon.dns_name

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_ssl_protocols = ["TLSv1.2"]
      origin_protocol_policy = "https-only"
    }
  }

  origin_group {
    origin_id = "mastodon"

    failover_criteria {
      status_codes = [404]
    }

    member {
      origin_id = aws_s3_bucket.mastodon-static.bucket_regional_domain_name
    }
    member {
      origin_id = aws_lb.mastodon.dns_name
    }

   }

  dynamic "ordered_cache_behavior" {
    for_each = local.application_paths

    content {
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false
      default_ttl            = 0
      max_ttl                = 0
      min_ttl                = 0
      path_pattern           = ordered_cache_behavior.value
      smooth_streaming       = false
      trusted_key_groups     = []
      trusted_signers        = []
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
      target_origin_id           = aws_lb.mastodon.dns_name
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    target_origin_id           = "mastodon"
 }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:055237546114:certificate/c4a4539a-a2c3-4c63-b133-ab29ea03da1e"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  wait_for_deployment = false
}
