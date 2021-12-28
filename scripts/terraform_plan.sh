#!/bin/bash
set -eu -o pipefail

if [[ -z "${ARTIFACT_SECRET_KEY}" ]]; then
    echo "Unable to encrypt terraform plan; aborting"
    exit 1
fi

pushd "${AWS_DEFAULT_REGION}"

# Initialize a new or existing Terraform working directory
# by creating initial files, loading any remote state, downloading modules, etc.
terraform init

# Checks that all Terraform configuration files adhere to a canonical format
terraform fmt -check

# Generates an execution plan for Terraform
terraform plan -out ./tfplan.zip

# Encrypt the plan with a random key
openssl enc -pass env:ARTIFACT_SECRET_KEY \
    -e -aes-256-ctr -pbkdf2 \
    -in ./tfplan.zip -out "../tfplan-${AWS_DEFAULT_REGION}.enc"
