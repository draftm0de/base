#!/bin/bash
CADDY_IMAGE_NAME="a"
NGINX_IMAGE_NAME="a"
SEARCH="CADDY"
ENV_NAME="${SEARCH}_IMAGE_NAME"
eval IMAGE_NAME=\$ENV_NAME
echo "name:${IMAGE_NAME}"
exit 1


source .env
if [ -z "$1" ]; then
  FILTER="draftmode/base."
else
  FILTER="draftmode/-$1*"
fi
docker rmi -f $(docker images "$FILTER" -a -q)
