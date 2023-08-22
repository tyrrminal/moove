#!/bin/bash
set -e

include_custom_modules() {
  if [ -n "$PERL_CUSTOM_MODULE_PATH" ]; then
    DIRS=$(find $PERL_CUSTOM_MODULE_PATH/*/lib -maxdepth 0 -type d -printf "%p:" 2> /dev/null || true)
    export PERL5LIB="${DIRS}${PERL5LIB}"
    DIRS=$(find $PERL_CUSTOM_MODULE_PATH/*/bin -maxdepth 0 -type d -printf "%p:" 2> /dev/null || true)
    export PATH="${DIRS}${PATH}"
  fi
}

# Run specified command
case "$1" in
  lsp)
    include_custom_modules
    exec perl "${@:2}"
    ;;
  shell)
    include_custom_modules
    exec /bin/bash
    ;;
  devserver)
    echo "Starting server in development mode"
    include_custom_modules
    exec morbo -l 'http://*:8080' -w lib -w api -w cfg script/moove
    ;;
  prodserver)
    echo "Starting server in production mode"
    exec hypnotoad -f script/moove
    ;;
  minion)
    echo "starting minion worker"
    exec script/moove_minion minion worker "${@:2}"
    ;;
  dbmigration)
    echo "Deploying database migrations"
    exec script/moove migrate_schema
    ;;
  *)
    echo "Usage: $0 [devserver|prodserver|dbmigration|minion|shell|lsp]"
    exit 1
esac

exit 0
