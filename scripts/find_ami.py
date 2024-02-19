#!/usr/bin/env python

import boto3

ec2 = boto3.client('ec2')

images = ec2.describe_images(
    Filters=[
        {
            'Name': 'name',
            'Values': ['al2023-ami-2023.*'],
        },
        {
            'Name': 'architecture',
            'Values': ['arm64'],
        },
        {
            'Name': 'ena-support',
            'Values': ['true'],
        },
        {
            'Name': 'virtualization-type',
            'Values': ['hvm'],
        },
    ],
)['Images']

images.sort(key=lambda image: image['CreationDate'])
for ami in images:
    print(f"{ami['ImageId']} -> {ami['Name']}")



