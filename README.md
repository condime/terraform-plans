# Terraform Plans

This describes the main scope for running the [condi.me github org][1] itself.

## Running Terraform

PRs opened from branches in this repository trigger a `terraform plan` run in
a Github Action. When merged to the `production` branch, the changes can be
applied from a manually approved step (also as a github workflow action).

## Running Terraform Locally

Terraform 1.0 (or compatible) is needed. You can download a specific version
from the [terraform releases][2] page.

To execute the binary, you will need a consul token (for terraform state)
and access to clone and decrypt [condime/secrets][3] (for provider tokens).

For personal access tokens, secrets can be stored and sourced using [pass][4].

    $ pass edit condi.me/terraform-plans
    $ source <(pass condi.me/terraform-plans)

For group shared access tokens, secrets can be stored using [blackbox][5].

    $ cd ~/src/condime/terraform-plans
    $ source <(blackbox_cat condi.me/terraform-plans)

If you don't have passwordstore or blackbox installed, in a pinch you can
use `git` and `gpg` directly to access the secrets.

With credentials now in the environment, you can now `init` and `plan` the
terraform runs.

    $ cd ./eu-west-2  # or any region under management
    $ terraform init
    $ terraform plan -o output.tfplan

## Consul ACL Policy

State is stored using the consul backend hosted at consul.condi.me, access is
granted with the following Consul ACL Policy.

```hcl
key_prefix "condime/terraform_state" {
  policy = "write"
}

session_prefix "" {
  policy = "write"
}
```

[1]: https://github.com/condime
[2]: https://github.com/hashicorp/terraform/releases
[3]: https://github.com/condime/secrets
[4]: https://passwordstore.org
[5]: https://github.com/stackexchange/blackbox
