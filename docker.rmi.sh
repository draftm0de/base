#!/bin/bash
if [ -z "$1" ]; then
  FILTER="draftmode/base."
else
  FILTER="draftmode/-$1*"
fi
docker rmi -f $(docker images "$FILTER" -a -q)
