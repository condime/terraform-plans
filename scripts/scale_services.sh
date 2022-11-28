#!/bin/bash
set -e

SERVICE_NAME="${1}"
DESIRED_COUNT="${2}"

if [[ -z "${SERVICE_NAME}" ]]; then
    echo "Usage: ${0} <service_name> [<desired_count>]"
    exit 1
fi

CURRENT_DESIRED_COUNT="$(
    aws ecs describe-services --services "${SERVICE_NAME}" \
        | jq -r '.services[0].desiredCount'
)"

echo "Current Desired Count: ${CURRENT_DESIRED_COUNT}"

if [[ -z "${DESIRED_COUNT}" ]]; then
    exit 0
fi

NEW_DESIRED_COUNT="$(
    aws ecs update-service \
        --service "${SERVICE_NAME}" --desired-count "${DESIRED_COUNT}" \
        | jq -r '.service.desiredCount'
)"
echo "New Desired Count: ${NEW_DESIRED_COUNT}"
