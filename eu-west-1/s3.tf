#--- nfra.club
resource "aws_s3_bucket" "mastodon-static" {
  bucket = "nfra-club"
}

resource "aws_s3_bucket_acl" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id
  policy = data.aws_iam_policy_document.mastodon-static.json
}

data "aws_iam_policy_document" "mastodon-static" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mastodon-static.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.mastodon-assets.arn,
      ]
    }
  }
}

resource "aws_s3_bucket_versioning" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id

  versioning_configuration {
    status = "Enabled"
  }
}

#--- useruploads.nfra.club
resource "aws_s3_bucket" "mastodon-useruploads" {
  bucket = "nfraclubuserassets"
}

resource "aws_s3_bucket_acl" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id
  policy = data.aws_iam_policy_document.mastodon-useruploads.json
}

data "aws_iam_policy_document" "mastodon-useruploads" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mastodon-useruploads.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.mastodon-useruploads.arn,
      ]
    }
  }
}

resource "aws_s3_bucket_versioning" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id

  versioning_configuration {
    status = "Enabled"
  }
}
