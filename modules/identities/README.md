# Application Login Identities

This module uses AWS Cognito to authenticate users from Identity Providers to Applicaitons.

In Cognito, we setup a single `main` User Pool. Users can be created in the pools manually,
either via Terraform or in the AWS Console and need to be authenticated using the Hosted App in Cognito.
The pool is defined in `userpool.tf`

Additionally, Users can be added to the Pool from 3rd party Identity Providers.
For example, Slack (an OAuth provider, but not a fully compliant OIDC service) can be our source
of users, based on people who are present in the condi.slack.com workspace.
This provider is defined in `provider_slack.tf`, and needs OAuth tokens from a dedicated slack app.

Applications that users login to are created in `app_*.tf`. This is how we can create new OIDC server
tokens for applications that support OIDC based logins.
An example is in `app_demoapp.tf`. You will need to contact @bencord0 to extract the generated secrets.
