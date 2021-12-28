#!/bin/bash
set -eu -o pipefail

if [ -z "${ARTIFACT_SECRET_KEY}" ]; then
    echo "Unable to decrypt terraform plan; aborting"
    exit 1
fi

# Decrypt the plan
openssl enc -pass env:ARTIFACT_SECRET_KEY \
    -d -aes-256-ctr -pbkdf2 \
    -in ../tfplan.enc -out tfplan.zip

# Execute the saved plan
terraform apply ./tfplan.zip
