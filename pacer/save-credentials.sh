#!/bin/sh

. $(dirname $0)/../config.sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 <pacer username> <pacer password>"
  exit 1
fi

curl -s -XPOST $COURTAPI_BASE_URL/pacer/credentials \
  -d pacer_user="$1" -d pacer_pass="$2"
