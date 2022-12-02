#!/bin/bash

EC2_INSTANCE="$(aws ec2 describe-instances --filters Name=tag:Name,Values=nat --filters Name=instance-state-name,Values=running| jq -r '.Reservations[0].Instances[0].InstanceId')"
exec aws ssm start-session --target "${EC2_INSTANCE}"
