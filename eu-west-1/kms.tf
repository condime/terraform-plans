data "aws_kms_key" "ecr" {
  key_id = "alias/aws/ecr"
}
