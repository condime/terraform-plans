#!/bin/bash
set -e

TASK_ARN="$(aws ecs list-tasks --service-name mastodon-sidekiq | jq -r '.taskArns[0]')"
exec aws ecs execute-command --cluster default --task "${TASK_ARN}" --container sidekiq --interactive --command /bin/bash
