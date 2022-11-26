resource "aws_ecr_repository" "mastodon" {
  name = "mastodon"

  force_delete         = true
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_key.ecr.arn
  }
}
