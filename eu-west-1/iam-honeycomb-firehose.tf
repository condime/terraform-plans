resource "aws_iam_role" "honeycomb-firehose" {
  name               = "honeycomb-firehose"
  assume_role_policy = data.aws_iam_policy_document.assume-firehose.json
}

resource "aws_iam_role_policy" "honeycomb-firehose-s3" {
  name   = "honeycomb-firehose-s3"
  role   = aws_iam_role.honeycomb-firehose.id
  policy = data.aws_iam_policy_document.honeycomb-firehose-s3.json
}

# Used if we want to transform the logs before forwarding them to honeycomb
resource "aws_iam_role_policy" "honeycomb-firehose-lambda" {
  count  = 0
  name   = "honeycomb-firehose-lambda"
  role   = aws_iam_role.honeycomb-firehose.id
  policy = data.aws_iam_policy_document.honeycomb-firehose-lambda.json
}

data "aws_iam_policy_document" "assume-firehose" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "honeycomb-firehose-s3" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.honeycomb-s3.arn,
      "${aws_s3_bucket.honeycomb-s3.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "honeycomb-firehose-lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      # "${var.lambda_transform_arn}:*"
    ]
  }
}
