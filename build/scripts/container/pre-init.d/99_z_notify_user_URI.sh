#!/usr/bin/env sh
if [ -n "$LOCAL_HOSTNAME" ] && [ -n "$LOCAL_PORT" ]; then
  printf "\nVisit your instance at:"
  printf "\nhttp://%s:%s" "$LOCAL_HOSTNAME" "$LOCAL_PORT"
  printf "\n"
fi
