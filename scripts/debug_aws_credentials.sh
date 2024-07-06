#!/bin/bash
set -ex

echo "AWS - Get Caller Identity"
aws sts get-caller-identity

echo
echo "AWS_ROLE_ARN                = ${AWS_ROLE_ARN}"
echo "AWS_WEB_IDENTITY_TOKEN_FILE = ${AWS_WEB_IDENTITY_TOKEN_FILE}"
stat -t "${AWS_WEB_IDENTITY_TOKEN_FILE}"
