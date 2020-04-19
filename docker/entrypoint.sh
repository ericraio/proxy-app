#!/bin/bash
set -e

cp -a /app/public /data/

exec "$@"
