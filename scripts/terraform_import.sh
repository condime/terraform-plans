#!/bin/bash
set -eu -o pipefail

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "Region not set; aborting"
    exit 1
fi

if [[ -z "${1}" ]]; then
    echo "Resource Address not set; aborting"
    exit 1
fi

if [[ -z "${2}" ]]; then
    echo "Resource ID not set; aborting"
    exit 1
fi


# Checks that all Terraform configuration files adhere to a canonical format
terraform fmt -check -diff -recursive

pushd "${AWS_DEFAULT_REGION}"

# Initialize a new or existing Terraform working directory
# by creating initial files, loading any remote state, downloading modules, etc.
terraform init

# Imports the terraform resource
terraform import "${1}" "${2}"
