#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <file_to_serve>"
  exit 1
fi

export FILE="$1"
bundle exec rackup -s puma