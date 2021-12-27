resource "aws_ecrpublic_repository" "blog" {
  repository_name = "blog"

  # ECR Public Repositories are only available in us-east-1
  provider = aws.us_east_1
}
