variable "region" {
  default = "eu-west-1"
}

data "consul_keys" "mastodon" {
  key {
    name = "database_url"
    path = "condime/terraform_state/mastodon/database_url"
  }

  key {
    name = "otp_secret"
    path = "condime/terraform_state/mastodon/otp_secret"
  }

  key {
    name = "secret_key_base"
    path = "condime/terraform_state/mastodon/secret_key_base"
  }

  key {
    name = "smtp_password"
    path = "condime/terraform_state/mastodon/smtp_password"
  }

  key {
    name = "vapid_private_key"
    path = "condime/terraform_state/mastodon/vapid_private_key"
  }

  key {
    name = "vapid_public_key"
    path = "condime/terraform_state/mastodon/vapid_public_key"
  }
}

data "consul_keys" "honeycomb" {
  key {
    name = "honeycomb_api_key"
    path = "condime/terraform_state/honeycomb/honeycomb_api_key"
  }
}
