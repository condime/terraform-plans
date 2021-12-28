resource "random_uuid" "uuid" {}

module "identities" {
  source = "./identities"

  oidc_client_id     = local.slack_oidc_client_id
  oidc_client_secret = local.slack_oidc_client_secret
}

resource "aws_iam_openid_connect_provider" "main" {
  url = module.identities.cognito_url

  client_id_list = [
    module.identities.cognito_client_id,
  ]

  thumbprint_list = [
    # this is a guess, based on a test account
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}

module "registry" {
  source = "./registry"
}
