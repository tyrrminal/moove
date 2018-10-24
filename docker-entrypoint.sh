#!/bin/bash
set -e

if [ "$1" = "devserver" ]; then 
  echo "Starting server in development mode"
  exec carton exec morbo -l 'http://*:8080' script/cardio_tracker

elif [ "$1" = "prodserver" ]; then
  echo "Starting server in production mode"
  exec carton exec hypnotoad -f script/cardio_tracker

elif [ "$1" = "snapshot" ]; then
  echo "Copying cpanfile.snapshot"
  exec carton install
  
fi
