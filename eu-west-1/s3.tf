#--- nfra.club
resource "aws_s3_bucket" "mastodon-static" {
  bucket = "nfra-club"
}

resource "aws_s3_bucket_acl" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id
  policy = data.aws_iam_policy_document.mastodon-static.json
}

data "aws_iam_policy_document" "mastodon-static" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mastodon-static.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_cors_configuration" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_versioning" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "mastodon-static" {
  bucket = aws_s3_bucket.mastodon-static.id

  index_document {
    suffix = "index.html"
  }
}

#--- useruploads.nfra.club
resource "aws_s3_bucket" "mastodon-useruploads" {
  bucket = "nfraclubuserassets"
}

resource "aws_s3_bucket_acl" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id
}

resource "aws_s3_bucket_policy" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id
  policy = data.aws_iam_policy_document.mastodon-useruploads-public-read.json
}

data "aws_iam_policy_document" "mastodon-useruploads-public-read" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mastodon-useruploads.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_cors_configuration" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_versioning" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "mastodon-useruploads" {
  bucket = aws_s3_bucket.mastodon-useruploads.id

  index_document {
    suffix = "index.html"
  }
}
