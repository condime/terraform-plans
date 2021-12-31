resource "aws_iam_role" "slack-users" {
  name               = "SlackUser"
  assume_role_policy = data.aws_iam_policy_document.assume-slack-users.json
}

# Only permit users logged in from the `condi.slack.com` workspace
data "aws_iam_policy_document" "assume-slack-users" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        # Slack doesn't support OIDC
        # But, we can proxy their OAuth2-only implementation through
        # AWS Cognito User Pools, and add OIDC capabilities.
        #
        # Slack is then only used for Authentication, and cannot provide
        # differentiated access to resources without additional help.
        #
        # This is the ARN to the entire User Pool.
        #
        # TODO: Provide access to different IAM Roles depending on Cognito
        #       User Pool Groups (manually managed?)
        var.identity_provider_arn,
      ]
    }

    condition {
      test = "StringEquals"

      # Permit id_tokens issued to this specific user_pool_client
      # e.g. cognito-idp.<region>.amazonaws.com/<userpool_id>
      variable = "${var.oidc_provider_user_pool_endpoint}:aud"

      values = [
        var.oidc_provider_user_pool_client_id,
      ]
    }

    # Without further conditions, any user able to authenticate
    # with this User Pool can get access to this IAM role.
    # TODO: Add additional conditions based on the contents
    #       of the id_token, e.g. specific claims such as `cognito:group`.
    # https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-the-id-token.html
  }
}
