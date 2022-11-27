#!/bin/bash
set -e

IMAGE="ghcr.io/bencord0/mastodon:master"
TARGET_REPOSITORY="055237546114.dkr.ecr.eu-west-1.amazonaws.com"
TARGET_IMAGE="${TARGET_REPOSITORY}/mastodon:4.0.2"

aws ecr get-login-password \
    | docker login --username AWS --password-stdin "${TARGET_REPOSITORY}"

docker pull "${IMAGE}"
docker tag "${IMAGE}" "${TARGET_IMAGE}"
docker push "${TARGET_IMAGE}"

IMAGE_DIGEST="$(docker inspect "${IMAGE}" \
    | jq -r '.[0].RepoDigests[0]' \
    | cut -d@ -f2)"
sed -i -e "s/^  container_image_tag = .*\$/  container_image_tag = \"@${IMAGE_DIGEST}\"/" eu-west-1/ecs.tf
