#!/bin/sh

. $(dirname $0)/../config.sh

if [ $# -ne 1 ]; then
  echo "Usage: $0 <court id>"
  exit 1
fi

curl -s -XGET $COURTAPI_BASE_URL/courts/pacer/$1
