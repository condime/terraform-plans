#!/bin/bash

EC2_INSTANCE="$(aws ec2 describe-instances --filters Name=tag:Name,Values=nat --filters Name=instance-state-name,Values=running| jq -r '.Reservations[0].Instances[0].InstanceId')"

exec aws ec2 modify-instance-attribute --instance-id "${EC2_INSTANCE}" --no-source-dest-check
