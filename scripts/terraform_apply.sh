#!/bin/bash
set -eu -o pipefail

if [ -z "${ARTIFACT_SECRET_KEY}" ]; then
    echo "Unable to decrypt terraform plan; aborting"
    exit 1
fi

pushd "${AWS_DEFAULT_REGION}"

# Decrypt the plan
openssl enc -pass env:ARTIFACT_SECRET_KEY \
    -d -aes-256-ctr -pbkdf2 \
    -in "../tfplan-${AWS_DEFAULT_REGION}.enc" -out tfplan.zip

# Download dependencies
terraform init

# Execute the saved plan
terraform apply ./tfplan.zip
