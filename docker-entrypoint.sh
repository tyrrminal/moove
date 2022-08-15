#!/bin/bash
set -e

include_custom_modules() {
  if [ -n "$PERL_CUSTOM_MODULE_PATH" ]; then
    DIRS=$(find $PERL_CUSTOM_MODULE_PATH/* -maxdepth 0 -type d)
    export PERL5LIB="$(echo $DIRS | sed s%$%:%    )${PERL5LIB}"
    export     PATH="$(echo $DIRS | sed s%$%/bin:%)${PATH}"
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
    echo "Usage: $0 [devserver|prodserver|dbmigration|shell|lsp]"
    exit 1
esac

exit 0
