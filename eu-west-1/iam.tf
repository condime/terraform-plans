resource "aws_iam_instance_profile" "nat" {
  name = "nat"
  role = aws_iam_role.nat.name
}

resource "aws_iam_role" "nat" {
  name               = "nat"
  description        = "EC2 Instance Role for NAT"
  assume_role_policy = data.aws_iam_policy_document.assume-ec2.json
}

data "aws_iam_policy_document" "assume-ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "nat" {
  role       = aws_iam_role.nat.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "nat-config-reader" {
  role       = aws_iam_role.nat.id
  policy_arn = aws_iam_policy.config-reader.arn
}

resource "aws_iam_policy" "config-reader" {
  name   = "ConfigReader"
  policy = data.aws_iam_policy_document.config-reader.json
}

data "aws_iam_policy_document" "config-reader" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.key-HyXG1o",
      "arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.pem-1oLgLZ",
    ]
  }
}

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
  policy_arn = aws_iam_policy.mastodon-task-role.arn
}

resource "aws_iam_policy" "mastodon-task-role" {
  name   = "mastodon-task-role"
  policy = data.aws_iam_policy_document.mastodon-task-role.json
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

data "aws_iam_policy_document" "mastodon-task-role" {
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

  # https://aws.amazon.com/premiumsupport/knowledge-center/ecs-error-execute-command/
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_user" "mastodon-useruploads" {
  name = "mastodon-user-assets"
}

resource "aws_iam_user_policy_attachment" "mastodon-useruploads" {
  user       = aws_iam_user.mastodon-useruploads.id
  policy_arn = aws_iam_policy.mastodon-task-role.arn
}

resource "aws_iam_access_key" "mastodon-useruploads" {
  user = aws_iam_user.mastodon-useruploads.id
}
