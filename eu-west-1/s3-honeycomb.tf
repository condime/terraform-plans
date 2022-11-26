# Used as a deadletter bucket for unprocessed messages
resource "aws_s3_bucket" "honeycomb-s3" {
  bucket_prefix = "honeycomb-forwarder"
  force_destroy = true
}
