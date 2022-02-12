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

  attribute_mapping = {
    "username" = "sub"
    "email"    = "email"
  }
}
