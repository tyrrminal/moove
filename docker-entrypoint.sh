#!/bin/bash
set -e

if [ -n "$TZ" ]; then
    echo ${TZ} >/etc/timezone && \
      ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
      dpkg-reconfigure -f noninteractive tzdata
    echo "Container timezone set to: $TZ"
fi

case "$1" in
  devserver)
    echo "Starting server in development mode"
    exec morbo -l 'http://*:8080' -w api -w lib script/cardio_tracker
    ;;
  prodserver)
    echo "Starting server in production mode"
    exec hypnotoad -f script/cardio_tracker
    ;;
  *)
    echo "Usage: $0 [devserver|prodserver]"
    exit 1
esac

exit 0
