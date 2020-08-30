#!/bin/bash
set -e

case "$1" in
  devserver)
    echo "Starting server in development mode"
    exec morbo -l 'http://*:8080' -w lib -w api -w cfg script/moove
    ;;
  prodserver)
    echo "Starting server in production mode"
    exec hypnotoad -f script/moove
    ;;
  dbmigration)
    echo "Deploying database migrations"
    exec script/moove migrate_schema
    ;;
  *)
    echo "Usage: $0 [devserver|prodserver|dbmigration]"
    exit 1
esac

exit 0