#!/bin/bash
source .env
if [ -z "$1" ]; then
  FILTER="${DOCKER_NAMESPACE}/${IMAGE_PREFIX}*"
else
  FILTER="${DOCKER_NAMESPACE}/-$1*"
fi
echo ":$FILTER:"
docker rmi -f $(docker images "$FILTER" -a -q)
