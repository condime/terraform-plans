#!/bin/bash

NAME="${1:-nat}"

EC2_INSTANCE="$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}" "Name=instance-state-name,Values=running" \
    | jq -r '.Reservations[0].Instances[0].InstanceId')"

echo "Connecting to EC2 Instance: ${NAME} - ${EC2_INSTANCE}"
exec aws ssm start-session --target "${EC2_INSTANCE}"
