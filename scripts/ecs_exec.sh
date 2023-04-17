#!/bin/bash
set -e

SERVICE_NAME="${1:-mastodon-web}"
declare -A CONTAINER_NAMES=(
    [mastodon-web]=web
    [mastodon-sidekiq]=sidekiq
)
CONTAINER_NAME="${CONTAINER_NAMES[${SERVICE_NAME}]}"

TASK_ARN="$(aws ecs list-tasks --service-name "${SERVICE_NAME}" | jq -r '.taskArns[0]')"
exec aws ecs execute-command --cluster default --task "${TASK_ARN}" --container "${CONTAINER_NAME}" --interactive --command /bin/bash
