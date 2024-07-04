#!/bin/bash
#set -e

y=0
ARGUMENTS=( "$@" )
while [[ $y -lt ${#ARGUMENTS[@]} ]]
do
  ARGUMENT=${ARGUMENTS[$y]}
  case ${ARGUMENT} in
    --connect=*)
      PORT="${ARGUMENT#*=}"
      (cgi-fcgi -bind -connect "${PORT}") > /dev/null
    ;;
    --connect)
      (cgi-fcgi -bind -connect :9000) > /dev/null
    ;;
    *)
    ;;
  esac
  (( y++))
done
exit 0
