#!/bin/bash

echo "AWS - Get Caller Identity"
aws sts get-caller-identity

echo
echo "AWS ROLE DATA"
echo "AWS_ROLE_ARN = ${AWS_ROLE_ARN}"
echo "AWS_WEB_IDENTITY_TOKEN_FILE = ${AWS_WEB_IDENTITY_TOKEN_FILE}"
ls -l "${AWS_WEB_IDENTITY_TOKEN_FILE}"
echo
echo "GITHUB_ENV = ${GITHUB_ENV}"
cat "${GITHUB_ENV}"
