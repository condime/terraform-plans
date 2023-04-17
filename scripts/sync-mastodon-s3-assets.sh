#!/bin/bash

exec aws s3 cp --recursive /usr/share/mastodon/public/ s3://nfra-club/
