resource "aws_cognito_user_pool_client" "reborncode" {
  name         = "Sandstorm (rebornco.de)"
  user_pool_id = aws_cognito_user_pool.main.id

  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  callback_urls = [
    "https://rebornco.de/_oauth/oidc",
  ]

  supported_identity_providers = [
    aws_cognito_identity_provider.slack.provider_name,
  ]

  # list of "code", "implicit", or "client_credentials"
  allowed_oauth_flows = [
    "code",
    "implicit"
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile",
  ]

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client#explicit_auth_flows
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}
