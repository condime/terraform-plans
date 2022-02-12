resource "aws_cognito_user_pool" "main" {
  name = "condi.me"
}

resource "aws_cognito_user_pool_domain" "main" {
  # Amazon Cognito managed domain
  domain       = "condi"
  user_pool_id = aws_cognito_user_pool.main.id
}
