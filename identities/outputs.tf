output "cognito_url" {
  value = "https://cognito-idp.eu-west-2.amazonaws.com/${aws_cognito_user_pool.main.id}"
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.main.id
}

output "cognito_client_secret" {
  value = aws_cognito_user_pool_client.main.client_secret
}
