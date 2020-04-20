#!/bin/bash
set -e

yarn install
bundle exec rails assets:precompile
bundle exec rails webpacker:compile

cp -a /app/public /data/

exec "$@"
