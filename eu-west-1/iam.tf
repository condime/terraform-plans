resource "aws_iam_role" "mastodon-execution-role" {
  name               = "mastodon-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume-ecs-tasks.json
}

resource "aws_iam_role_policy_attachment" "mastodon-execution-role" {
  role       = aws_iam_role.mastodon-execution-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "mastodon-task-role" {
  name               = "mastodon-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume-ecs-tasks.json
}

resource "aws_iam_role_policy_attachment" "mastodon-task-role" {
  role       = aws_iam_role.mastodon-task-role.id
  policy_arn = aws_iam_policy.mastodon-useruploads.arn
}


resource "aws_iam_policy" "mastodon-useruploads" {
  name   = "mastodon-user-assets"
  policy = data.aws_iam_policy_document.mastodon-useruploads.json
}

data "aws_iam_policy_document" "assume-ecs-tasks" {
  version = "2008-10-17"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mastodon-useruploads" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketWebsite",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectAttributes",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionTagging",
      "s3:PutObject",
      "s3:PutObjectRetention",
      "s3:PutObjectVersionAcl",
    ]

    resources = [
      aws_s3_bucket.mastodon-useruploads.arn,
      "${aws_s3_bucket.mastodon-useruploads.arn}/*",
    ]
  }
}

resource "aws_iam_user" "mastodon-useruploads" {
  name = "mastodon-user-assets"
}

resource "aws_iam_user_policy_attachment" "mastodon-useruploads" {
  user       = aws_iam_user.mastodon-useruploads.id
  policy_arn = aws_iam_policy.mastodon-useruploads.arn
}

resource "aws_iam_access_key" "mastodon-useruploads" {
  user = aws_iam_user.mastodon-useruploads.id
}
