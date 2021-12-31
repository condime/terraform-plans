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
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}
