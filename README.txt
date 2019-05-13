Terraform Plans
===============

This describes the Geopoiesis scope for running terraform plans.

Running Geopoiesis
------------------

This instance of Geopoiesis is running at https://geopoiesis.condi.me
and managed by https://meta-geopoiesis.condi.me.

Geopoiesis Environment
----------------------

These variables are set in the Environmment tab so that per-run state
is saved in S3. You don't need to use backend locking (geopoiesis
itself becomes the lock as all runs are serialised by the queue).

TF_CLI_ARGS_init

  -backend-config='access_key=...' \
  -backend-config='secret_key=...' \
  -backend-config='bucket=$bucket' \
  -backend-config='key=$statefile' \
  -backend-config='region=...' 

This AWS user only needs access to manupaulate the state file.
If you are not using the s3 backend, you don't need to create this AWS user.

Example IAM Policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::$bucket/$statefile",
                "arn:aws:s3:::$bucket/$another_statefile"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::$bucket"
        }
    ]
}

```

The following variables are only needed to configure terraform providers.

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

Note: These are _not_ needed if you are not managing AWS resources.
