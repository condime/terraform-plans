locals {
  origin_request_policy = {
    AllViewer                     = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    AllViewerAndCloudFrontHeaders = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    CORSCustomOrigin              = "59781a5b-3903-41f3-afcb-af62929ccde1"
    CORSS3Origin                  = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  }

  cache_policy = {
    CachingDisabled                        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    CachingOptimized                       = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    CachingOptimizedForUncompressedObjects = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
  }

  response_headers = {
    SimpleCORS                   = "60669652-455b-4ae9-85a4-c4c02393f86c"
    SecurityHeaders              = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    CORSPreflight                = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
    CORSSecurityHeaders          = "e61eb60c-9c35-4d20-a928-2b84e02af89c"
    CORSPreflightSecurityHeaders = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  description                       = "Default origin access controls"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "mastodon-useruploads" {
  aliases = [
    "useruploads.nfra.club",
  ]

  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.mastodon-useruploads.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.mastodon-useruploads.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    origin_request_policy_id   = local.origin_request_policy["CORSS3Origin"]
    cache_policy_id            = local.cache_policy["CachingOptimized"]
    response_headers_policy_id = local.response_headers["CORSPreflightSecurityHeaders"]

    target_origin_id = aws_s3_bucket.mastodon-useruploads.bucket_regional_domain_name
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

resource "aws_cloudfront_distribution" "mastodon-assets" {
  aliases = [
    "static.nfra.club",
  ]

  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.mastodon-static.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.mastodon-static.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id            = local.cache_policy["CachingOptimized"]
    origin_request_policy_id   = local.origin_request_policy["CORSS3Origin"]
    response_headers_policy_id = local.response_headers["CORSPreflightSecurityHeaders"]

    target_origin_id = aws_s3_bucket.mastodon-static.bucket_regional_domain_name
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
