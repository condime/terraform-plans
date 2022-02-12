resource "random_uuid" "uuid" {}

module "identities" {
  source = "../modules/identities"

  oidc_client_id     = local.slack_oidc_client_id
  oidc_client_secret = local.slack_oidc_client_secret
}

resource "aws_iam_openid_connect_provider" "main" {
  url = module.identities.cognito_url

  client_id_list = [
    module.identities.user_pool_client_id,
  ]

  thumbprint_list = [
    # This is the thumbprint for cognito-idp.eu-west-2.amazonaws.com
    # and is not sufficient to uniquely identify our own user pools
    # $ openssl s_client -servername cognito-idp.eu-west-2.amazonaws.com \
    #     -showcerts -connect cognito-idp.eu-west-2.amazonaws.com:443 \
    #     | openssl x509 -fingerprint -noout \
    #     | cut -d'=' -f 2 | sed -e 's/://g'
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}

module "slack-users-role" {
  source = "../modules/roles/slack-users"

  identity_provider_arn             = aws_iam_openid_connect_provider.main.arn
  oidc_provider_user_pool_endpoint  = module.identities.user_pool_endpoint
  oidc_provider_user_pool_client_id = module.identities.user_pool_client_id
}
