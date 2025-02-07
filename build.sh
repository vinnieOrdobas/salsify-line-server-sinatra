#!/bin/bash

# Exit if command exits or errors
set -e

# install bundler if not installed
if ! gem spec bundler > /dev/null 2>&1; then
  echo "Installing Bundler..."
  gem install bundler
fi

# install dependencies
echo "Installing dependencies..."
bundle install

echo "Dependencies installed."

