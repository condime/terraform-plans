#!/bin/bash
set -eu -o pipefail

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "Region not set; aborting"
    exit 1
fi

# Checks that all Terraform configuration files adhere to a canonical format
terraform fmt -check -diff -recursive

pushd "${AWS_DEFAULT_REGION}"

# Initialize a new or existing Terraform working directory
# by creating initial files, loading any remote state, downloading modules, etc.
terraform init

# Refreshes the terraform resources
terraform refresh
