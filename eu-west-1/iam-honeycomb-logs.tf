resource "aws_iam_role" "honeycomb-logs" {
  name               = "honeycomb-logs"
  assume_role_policy = data.aws_iam_policy_document.assume-logs.json
}

resource "aws_iam_role_policy" "honeycomb-logs" {
  name   = "honeycomb-logs"
  role   = aws_iam_role.honeycomb-logs.id
  policy = data.aws_iam_policy_document.honeycomb-logs.json
}

data "aws_iam_policy_document" "assume-logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "honeycomb-logs" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.honeycomb.arn
    ]
  }
}
