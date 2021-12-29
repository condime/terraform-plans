resource "aws_cognito_user_pool" "main" {
  name = "condi.me"
}

resource "aws_cognito_user_pool_domain" "main" {
  # Amazon Cognito managed domain
  domain       = "condi"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "Demo App"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true
  callback_urls = [
    "http://localhost:8000/accounts/amazon-cognito/login/callback/"
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
  ]
}

resource "aws_cognito_identity_provider" "slack" {
  user_pool_id = aws_cognito_user_pool.main.id

  provider_name = "Slack"
  provider_type = "OIDC"

  provider_details = {
    attributes_request_method     = "POST"
    attributes_url_add_attributes = "false"
    authorize_scopes              = "openid"
    client_id                     = var.oidc_client_id
    client_secret                 = var.oidc_client_secret
    oidc_issuer                   = "https://slack.com"
  }
}
