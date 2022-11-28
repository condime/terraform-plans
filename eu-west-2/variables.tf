variable "region" {
  default = "eu-west-2"
}

data "consul_keys" "slack_oidc" {
  key {
    name = "client_id"
    path = "condime/terraform_state/slack_token/client_id"
  }

  key {
    name = "client_secret"
    path = "condime/terraform_state/slack_token/client_secret"
  }
}

locals {
  slack_oidc_client_id     = data.consul_keys.slack_oidc.var.client_id
  slack_oidc_client_secret = sensitive(data.consul_keys.slack_oidc.var.client_secret)
}
